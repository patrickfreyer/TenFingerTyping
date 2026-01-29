import SwiftUI

@main
struct TenFingerTypingApp: App {
    var body: some Scene {
        MenuBarExtra("10-Finger", systemImage: "keyboard.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
