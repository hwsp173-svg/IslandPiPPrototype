import Combine
import Foundation
import WebKit

@MainActor
final class BrowserState: ObservableObject {
    // MARK: – Published state
    @Published var urlString: String = ""
    @Published var currentURL: URL?
    @Published var pageTitle: String = ""
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false
    @Published var loadingProgress: Double = 0
    @Published var errorMessage: String?
    @Published var isFullscreen: Bool = false
    @Published var showingHome: Bool = true
    @Published var searchEngine: SearchEngine = .google

    // MARK: – WebView reference
    weak var webView: WKWebView?

    // MARK: – Search engines
    enum SearchEngine: String, CaseIterable, Identifiable {
        case google, duckDuckGo, bing
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .google: return "Google"
            case .duckDuckGo: return "DuckDuckGo"
            case .bing: return "Bing"
            }
        }
        func searchURL(for query: String) -> URL? {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            switch self {
            case .google: return URL(string: "https://www.google.com/search?q=\(encoded)")
            case .duckDuckGo: return URL(string: "https://duckduckgo.com/?q=\(encoded)")
            case .bing: return URL(string: "https://www.bing.com/search?q=\(encoded)")
            }
        }
    }

    // MARK: – Quick links
    struct QuickLink: Identifiable {
        let id = UUID()
        let title: String
        let url: URL
        let icon: String
        let color: (red: Double, green: Double, blue: Double)
    }

    static let quickLinks: [QuickLink] = [
        QuickLink(title: "Instagram", url: URL(string: "https://www.instagram.com")!, icon: "camera.fill", color: (0.88, 0.19, 0.42)),
        QuickLink(title: "YouTube", url: URL(string: "https://www.youtube.com")!, icon: "play.rectangle.fill", color: (1.0, 0.0, 0.0)),
        QuickLink(title: "Reddit", url: URL(string: "https://www.reddit.com")!, icon: "bubble.left.and.bubble.right.fill", color: (1.0, 0.27, 0.0)),
        QuickLink(title: "Google", url: URL(string: "https://www.google.com")!, icon: "magnifyingglass", color: (0.26, 0.52, 0.96)),
    ]

    // MARK: – Navigation
    func navigate(to input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        errorMessage = nil
        showingHome = false

        if looksLikeURL(trimmed) {
            let urlStr = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
            if let url = URL(string: urlStr) {
                urlString = urlStr
                webView?.load(URLRequest(url: url))
                return
            }
        }

        // Search query
        if let searchURL = searchEngine.searchURL(for: trimmed) {
            urlString = searchURL.absoluteString
            webView?.load(URLRequest(url: searchURL))
        }
    }

    func navigateToURL(_ url: URL) {
        errorMessage = nil
        showingHome = false
        urlString = url.absoluteString
        webView?.load(URLRequest(url: url))
    }

    func goBack() { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func reload() {
        if showingHome { return }
        webView?.reload()
    }
    func stopLoading() { webView?.stopLoading() }

    func goHome() {
        showingHome = true
        urlString = ""
        pageTitle = ""
        currentURL = nil
        errorMessage = nil
        webView?.load(URLRequest(url: URL(string: "about:blank")!))
    }

    func toggleFullscreen() {
        isFullscreen.toggle()
    }

    // MARK: – Helpers
    private func looksLikeURL(_ string: String) -> Bool {
        if string.contains("://") { return true }
        // Has domain-like structure: contains a dot and no spaces
        if string.contains(".") && !string.contains(" ") {
            let parts = string.split(separator: ".")
            if let last = parts.last, last.count >= 2 { return true }
        }
        return false
    }
}
