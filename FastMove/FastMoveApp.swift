import SwiftUI

@main
struct FastMoveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 850, minHeight: 550)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentMinSize)
    }
}