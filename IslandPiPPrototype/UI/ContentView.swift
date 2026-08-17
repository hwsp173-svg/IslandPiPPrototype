import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var browser: BrowserState
    @EnvironmentObject private var island: IslandState

    var body: some View {
        ZStack {
            if browser.showingHome {
                home
            } else {
                BrowserWebView()
                    .ignoresSafeArea(browser.isFullscreen ? .all : [])
                    .background(Color(.systemBackground))
            }

            DynamicIslandOverlay()
                .zIndex(10)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !browser.isFullscreen {
                BrowserToolbar()
            }
        }
        .statusBarHidden(browser.isFullscreen)
    }

    private var home: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 64))
                .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            
            Text("IslandBrowser")
                .font(.system(size: 34, weight: .bold))
            
            Text("Search the web with an interactive Dynamic Island overlay.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            
            VStack(spacing: 12) {
                Button {
                    browser.navigate("google.com")
                } label: {
                    Label("Search Google", systemImage: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    browser.navigate("apple.com")
                } label: {
                    Label("Visit Apple.com", systemImage: "apple.logo")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}
