import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var browser: BrowserState
    @EnvironmentObject private var island: IslandState

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                browserSurface
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            if island.isExpanded {
                                island.collapse()
                            }
                        },
                        including: .gesture
                    )

                DynamicIslandOverlay(
                    topSafeArea: proxy.safeAreaInsets.top,
                    containerWidth: proxy.size.width
                )
                    .zIndex(10)

                if browser.isFullscreen && !island.isExpanded {
                    FullscreenExitButton(topSafeArea: proxy.safeAreaInsets.top) {
                        browser.toggleFullscreen()
                    }
                    .zIndex(11)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.container, edges: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !browser.isFullscreen {
                BrowserToolbar()
            }
        }
        .statusBarHidden(browser.isFullscreen)
        .sheet(isPresented: $island.settingsPresented) {
            IslandSettingsView()
                .environmentObject(island)
        }
        .sheet(isPresented: $browser.showingShareSheet) {
            ShareSheet(items: browser.currentURL.map { [$0 as Any] } ?? [])
        }
    }

    @ViewBuilder
    private var browserSurface: some View {
        if browser.showingHome {
            BrowserHomeView()
        } else {
            BrowserWebView(state: browser)
                .background(Color(.systemBackground))
                .modifier(FullscreenWebViewModifier(isFullscreen: browser.isFullscreen))
        }
    }
}

private struct FullscreenWebViewModifier: ViewModifier {
    let isFullscreen: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isFullscreen {
            content.ignoresSafeArea()
        } else {
            content
        }
    }
}

private struct FullscreenExitButton: View {
    let topSafeArea: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.down.right.and.arrow.up.left")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(.black.opacity(0.72), in: Circle())
                .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Exit fullscreen")
        .padding(.top, topSafeArea + 8)
        .padding(.trailing, 16)
        .frame(maxWidth: .infinity, alignment: .topTrailing)
    }
}
