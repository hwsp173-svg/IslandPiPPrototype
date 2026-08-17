import SwiftUI

struct BrowserHomeView: View {
    @EnvironmentObject private var browserState: BrowserState
    @FocusState private var searchFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 36) {
                Spacer().frame(height: 60)

                // App title
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: "globe")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.38, green: 0.62, blue: 1.0), Color(red: 0.58, green: 0.40, blue: 1.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("IslandBrowser")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Text("Browse the web with a Dynamic Island")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Search field
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 15, weight: .medium))

                    TextField("Search or enter URL", text: $browserState.urlString)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.webSearch)
                        .submitLabel(.go)
                        .focused($searchFocused)
                        .onSubmit {
                            browserState.navigate(to: browserState.urlString)
                        }
                        .font(.system(size: 16))
                        .foregroundStyle(.white)

                    if !browserState.urlString.isEmpty {
                        Button {
                            browserState.urlString = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 20)

                // Quick links grid
                VStack(alignment: .leading, spacing: 14) {
                    Text("Quick Links")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ], spacing: 12) {
                        ForEach(BrowserState.quickLinks) { link in
                            Button {
                                browserState.navigateToURL(link.url)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: link.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color(red: link.color.red, green: link.color.green, blue: link.color.blue))
                                        .frame(width: 36, height: 36)
                                        .background(
                                            Color(red: link.color.red, green: link.color.green, blue: link.color.blue)
                                                .opacity(0.15),
                                            in: RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        )

                                    Text(link.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white)

                                    Spacer()
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white.opacity(0.06))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.09))
        .scrollDismissesKeyboard(.interactively)
    }
}
