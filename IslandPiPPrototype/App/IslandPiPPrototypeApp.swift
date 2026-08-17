import SwiftUI

@main
struct IslandPiPPrototypeApp: App {
    @StateObject private var controller = IslandController()
    @StateObject private var pipController = PiPController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller)
                .environmentObject(pipController)
                .preferredColorScheme(.dark)
                .onAppear { pipController.configureIfNeeded() }
        }
    }
}
