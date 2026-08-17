import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var browserState: BrowserState
    @EnvironmentObject private var islandState: IslandState

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.07, green: 0.07, blue: 0.09)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Island safe-area spacer – reserve space for the island
                // so the WKWebView never underlaps it
                if !browserState.isFullscreen {
                    Color.clear.frame(height: 44)
                }

                // Main content area
                if browserState.showingHome {
                    BrowserHomeView()
                        .transition(.opacity)
                } else {
                    // WKWebView
                    ZStack {
                        BrowserWebView()
                            .background(Color.white)

                        // Error overlay
                        if let error = browserState.errorMessage {
                            errorView(error)
                        }
                    }
                }

                // Bottom toolbar
                BrowserToolbar()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

            // Dynamic Island overlay – always on top
            DynamicIslandOverlay()
                .ignoresSafeArea()
        }
        .statusBarHidden(browserState.isFullscreen)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)
            Text("Page could not be loaded")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                browserState.reload()
            } label: {
                Text("Try Again")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15), in: Capsule())
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.07, green: 0.07, blue: 0.09))
    }
}
