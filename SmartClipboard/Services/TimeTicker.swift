import Observation
import Foundation

@Observable
final class TimeTicker {
    var tick: Int = 0
    private var timer: Timer?

    func start() {
        guard timer == nil else { return }
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick += 1
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
