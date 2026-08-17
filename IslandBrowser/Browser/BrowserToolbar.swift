import SwiftUI

struct BrowserToolbar: View {
    @EnvironmentObject private var browser: BrowserState
    @EnvironmentObject private var island: IslandState
    @FocusState private var addressFieldFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            if browser.isLoading {
                ProgressView(value: browser.progress)
                    .progressViewStyle(.linear)
                    .tint(.accentColor)
                    .frame(height: 2)
                    .padding(.horizontal, 18)
                    .transition(.opacity)
            }

            AddressBar(
                text: $browser.addressText,
                isLoading: browser.isLoading,
                isFocused: $addressFieldFocused,
                submit: submitAddress
            )

            HStack(spacing: 2) {
                ToolbarButton(systemName: "chevron.left", help: "Back", isEnabled: browser.canGoBack) {
                    browser.goBack()
                }
                ToolbarButton(systemName: "chevron.right", help: "Forward", isEnabled: browser.canGoForward) {
                    browser.goForward()
                }

                Spacer(minLength: 8)

                ToolbarButton(systemName: "arrow.clockwise", help: "Reload") {
                    browser.reload()
                }
                ToolbarButton(systemName: "square.and.arrow.up", help: "Share", isEnabled: browser.currentURL != nil) {
                    browser.share()
                }
                ToolbarButton(
                    systemName: browser.isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right",
                    help: browser.isFullscreen ? "Exit fullscreen" : "Enter fullscreen"
                ) {
                    browser.toggleFullscreen()
                }
                ToolbarButton(systemName: "ellipsis.circle", help: "Island controls") {
                    island.expand()
                }
            }
            .padding(.horizontal, 14)
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.primary.opacity(0.08))
                .frame(height: 0.5)
        }
        .animation(.easeInOut(duration: 0.18), value: browser.isLoading)
    }

    private func submitAddress() {
        browser.navigate(browser.addressText)
        addressFieldFocused = false
    }
}

private struct AddressBar: View {
    @Binding var text: String
    let isLoading: Bool
    var isFocused: FocusState<Bool>.Binding
    let submit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isLoading ? "arrow.clockwise" : "magnifyingglass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)
                .symbolEffect(.variableColor.iterative, isActive: isLoading)

            TextField("Search or enter website", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .textContentType(.URL)
                .submitLabel(.go)
                .focused(isFocused)
                .onSubmit(submit)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .lineLimit(1)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear address")
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(.primary.opacity(0.06), lineWidth: 0.5)
        }
        .padding(.horizontal, 14)
    }
}

private struct ToolbarButton: View {
    let systemName: String
    let help: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 34, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isEnabled ? .primary : .tertiary)
        .disabled(!isEnabled)
        .accessibilityLabel(help)
    }
}
