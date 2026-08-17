import SwiftUI

struct BrowserToolbar: View {
    @EnvironmentObject private var browserState: BrowserState
    @EnvironmentObject private var islandState: IslandState

    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // URL bar
            if !browserState.isFullscreen {
                urlBar
            }

            // Loading progress
            if browserState.isLoading {
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.38, green: 0.62, blue: 1.0), Color(red: 0.58, green: 0.40, blue: 1.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * browserState.loadingProgress, height: 2)
                        .animation(.linear(duration: 0.2), value: browserState.loadingProgress)
                }
                .frame(height: 2)
            }

            // Bottom toolbar
            bottomBar
        }
        .background(Color(red: 0.10, green: 0.10, blue: 0.12))
        .sheet(isPresented: $showSettings) {
            IslandSettingsView()
                .environmentObject(islandState)
                .environmentObject(browserState)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - URL Bar
    private var urlBar: some View {
        HStack(spacing: 8) {
            // Lock icon for HTTPS
            if let url = browserState.currentURL, url.scheme == "https", !browserState.showingHome {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.green.opacity(0.8))
            }

            TextField("Search or enter URL", text: $browserState.urlString)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.webSearch)
                .submitLabel(.go)
                .onSubmit {
                    browserState.navigate(to: browserState.urlString)
                }
                .font(.system(size: 14))
                .foregroundStyle(.white)

            if browserState.isLoading {
                Button { browserState.stopLoading() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            } else if !browserState.urlString.isEmpty && !browserState.showingHome {
                Button { browserState.reload() } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.07))
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack(spacing: 0) {
            // Back
            toolbarButton(icon: "chevron.left", disabled: !browserState.canGoBack) {
                browserState.goBack()
            }

            // Forward
            toolbarButton(icon: "chevron.right", disabled: !browserState.canGoForward) {
                browserState.goForward()
            }

            // Share
            toolbarButton(icon: "square.and.arrow.up", disabled: browserState.showingHome) {
                shareCurrentPage()
            }

            // Island settings
            toolbarButton(icon: "sparkles.rectangle.stack", disabled: false) {
                showSettings = true
            }

            // Fullscreen
            toolbarButton(icon: browserState.isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right", disabled: browserState.showingHome) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    browserState.toggleFullscreen()
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.bottom, 2)
    }

    private func toolbarButton(icon: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(disabled ? .white.opacity(0.25) : .white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .contentShape(Rectangle())
        }
        .disabled(disabled)
    }

    private func shareCurrentPage() {
        guard let url = browserState.currentURL else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            // Find the top-most presented controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController { topVC = presented }
            activityVC.popoverPresentationController?.sourceView = topVC.view
            topVC.present(activityVC, animated: true)
        }
    }
}
