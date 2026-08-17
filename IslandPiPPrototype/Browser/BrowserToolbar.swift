import SwiftUI

struct BrowserToolbar: View {
    @EnvironmentObject private var browser: BrowserState
    @EnvironmentObject private var island: IslandState
    @FocusState private var focused: Bool
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 4) {
            if browser.isLoading {
                ProgressView(value: browser.progress)
                    .progressViewStyle(.linear)
                    .tint(.blue)
                    .frame(height: 2)
            }

            HStack(spacing: 8) {
                Button { browser.goBack() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                }
                .disabled(!browser.canGoBack)

                Button { browser.goForward() } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .disabled(!browser.canGoForward)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 14))

                    TextField("Search or enter address", text: $browser.addressText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .focused($focused)
                        .submitLabel(.go)
                        .onSubmit {
                            browser.navigate(browser.addressText)
                            focused = false
                        }

                    if !browser.addressText.isEmpty {
                        Button {
                            browser.addressText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14))
                        }
                    }
                }
                .padding(.horizontal, 10)
                .frame(height: 38)
                .background(Color(.secondarySystemBackground), in: Capsule())

                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "circle.hexagonpath")
                        .font(.system(size: 17, weight: .medium))
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        browser.toggleFullscreen()
                    }
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 15, weight: .medium))
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
            .padding(.top, 4)
        }
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showingSettings) {
            IslandSettingsView()
        }
    }
}
