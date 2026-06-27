import AppKit

final class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int
    var onNewContent: ((String) -> Void)?

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    func start() {
        guard timer == nil else { return }
        let t = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.poll()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // Call after writing to the pasteboard ourselves so the next poll is skipped.
    func syncChangeCount() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    private func poll() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount
        if let string = pb.string(forType: .string), !string.isEmpty {
            onNewContent?(string)
        }
    }
}
