import Observation
import AppKit

@Observable
final class ClipboardStore {
    var items: [ClipboardItem] = []

    private let monitor = ClipboardMonitor()
    private let maxHistory = 100
    private let storageKey = "clipboard_history"

    init() {
        load()
        monitor.onNewContent = { [weak self] text in
            self?.addItem(text)
        }
        monitor.start()
    }

    func addItem(_ text: String) {
        guard items.first?.content != text else { return }
        let item = ClipboardItem(content: text, category: ContentDetector.detect(text))
        items.insert(item, at: 0)
        if items.count > maxHistory {
            items = Array(items.prefix(maxHistory))
        }
        save()
    }

    func remove(at offsets: IndexSet) {
        for index in offsets.sorted().reversed() {
            items.remove(at: index)
        }
        save()
    }

    func clear() {
        items.removeAll()
        save()
    }

    func copyToClipboard(_ item: ClipboardItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)
        monitor.syncChangeCount()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([ClipboardItem].self, from: data) else { return }
        items = saved
    }
}
