import SwiftUI
import AppKit

@main
struct SmartClipboardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var store = ClipboardStore()

    var body: some Scene {
        MenuBarExtra("SmartClip", systemImage: "doc.on.clipboard") {
            ContentView()
                .environment(store)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let alreadyRunning = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleID)
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }

        if !alreadyRunning.isEmpty {
            exit(0)
        }
    }
}
