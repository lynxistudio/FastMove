import SwiftUI

@main
struct FastMoveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, minHeight: 500)
        }
        .windowResizability(.contentMinSize)
    }
}
