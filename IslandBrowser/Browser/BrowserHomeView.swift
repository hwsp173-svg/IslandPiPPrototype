import SwiftUI

struct BrowserHomeView: View {
    @EnvironmentObject private var browser: BrowserState
    @FocusState private var searchFocused: Bool

    private let quickLinks: [QuickLink] = [
        QuickLink(title: "Google", host: "google.com", icon: "magnifyingglass", tint: .blue),
        QuickLink(title: "YouTube", host: "youtube.com", icon: "play.fill", tint: .red),
        QuickLink(title: "Reddit", host: "reddit.com", icon: "bubble.left.and.bubble.right.fill", tint: .orange),
        QuickLink(title: "Instagram", host: "instagram.com", icon: "camera.fill", tint: .purple),
        QuickLink(title: "TikTok", host: "tiktok.com", icon: "music.note", tint: .primary),
        QuickLink(title: "Wikipedia", host: "wikipedia.org", icon: "book.fill", tint: .indigo)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Spacer(minLength: 80)

                VStack(alignment: .leading, spacing: 8) {
                    Label("A calmer way to browse", systemImage: "circle.hexagongrid.fill")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.tint)

                    Text("IslandBrowser")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .tracking(-1)

                    Text("Your web, with a little more presence.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search the web", text: $browser.addressText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.webSearch)
                        .submitLabel(.go)
                        .focused($searchFocused)
                        .onSubmit {
                            browser.navigate(browser.addressText)
                            searchFocused = false
                        }
                    if !browser.addressText.isEmpty {
                        Button { browser.addressText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 17, style: .continuous))

                VStack(alignment: .leading, spacing: 14) {
                    Text("Quick links")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 12)], spacing: 12) {
                        ForEach(quickLinks) { link in
                            Button { browser.navigate(link.host) } label: {
                                VStack(alignment: .leading, spacing: 12) {
                                    Image(systemName: link.icon)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(link.tint)
                                    Text(link.title)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.primary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(.primary.opacity(0.06), lineWidth: 0.5)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 140)
        }
        .background(Color(.systemBackground))
    }
}

private struct QuickLink: Identifiable {
    let title: String
    let host: String
    let icon: String
    let tint: Color
    var id: String { host }
}
