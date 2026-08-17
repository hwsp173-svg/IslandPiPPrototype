import SwiftUI

@main
struct IslandBrowserApp: App {
    @StateObject private var browserState = BrowserState()
    @StateObject private var islandState = IslandState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(browserState)
                .environmentObject(islandState)
        }
    }
}
