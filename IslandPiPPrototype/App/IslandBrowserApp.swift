import SwiftUI

@main
struct IslandBrowserApp: App {
    @StateObject private var browser = BrowserState()
    @StateObject private var island = IslandState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(browser)
                .environmentObject(island)
                .preferredColorScheme(.dark)
        }
    }
}
