import Foundation
import SwiftUI
import WebKit

@MainActor
final class BrowserState: ObservableObject {
    @Published private(set) var currentURL: URL?
    @Published private(set) var pageTitle = ""
    @Published var addressText = ""
    @Published private(set) var isLoading = false
    @Published private(set) var progress = 0.0
    @Published private(set) var canGoBack = false
    @Published private(set) var canGoForward = false
    @Published var showingHome = true
    @Published var isFullscreen = false
    @Published private(set) var errorMessage: String?
    @Published var showingShareSheet = false

    weak var webView: WKWebView?

    var displayTitle: String {
        pageTitle.isEmpty ? (currentURL?.host ?? "IslandBrowser") : pageTitle
    }

    func attach(webView: WKWebView) {
        self.webView = webView
        if let currentURL {
            webView.load(URLRequest(url: currentURL))
        }
        updateNavigationState(from: webView)
    }

    func navigate(_ input: String) {
        guard let destination = BrowserDestination.resolve(input) else { return }
        navigate(to: destination)
    }

    func navigate(to url: URL) {
        currentURL = url
        addressText = url.absoluteString
        showingHome = false
        errorMessage = nil
        webView?.load(URLRequest(url: url))
    }

    func reload() {
        errorMessage = nil
        webView?.reload()
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func share() {
        guard currentURL != nil else { return }
        showingShareSheet = true
    }

    func toggleFullscreen() {
        withAnimation(.easeInOut(duration: 0.24)) {
            isFullscreen.toggle()
        }
    }

    func updateNavigationState(from webView: WKWebView) {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
    }

    func navigationDidStart(for webView: WKWebView) {
        isLoading = true
        errorMessage = nil
        updateNavigationState(from: webView)
    }

    func navigationDidFinish(for webView: WKWebView) {
        isLoading = false
        currentURL = webView.url
        addressText = webView.url?.absoluteString ?? addressText
        pageTitle = webView.title ?? ""
        progress = webView.estimatedProgress
        updateNavigationState(from: webView)
    }

    func navigationDidFail(for webView: WKWebView, error: Error) {
        isLoading = false
        updateNavigationState(from: webView)
        let nsError = error as NSError
        guard nsError.code != NSURLErrorCancelled else { return }
        errorMessage = nsError.localizedDescription
    }

    func updateProgress(_ value: Double) {
        progress = value
    }
}

enum BrowserDestination {
    static func resolve(_ input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let direct = directURL(from: trimmed) {
            return direct
        }

        let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
        return URL(string: "https://www.google.com/search?q=\(encoded)")
    }

    private static func directURL(from value: String) -> URL? {
        let hasScheme = value.range(of: "^[a-zA-Z][a-zA-Z0-9+.-]*://", options: .regularExpression) != nil
        let candidate = hasScheme ? value : "https://\(value)"
        guard let url = URL(string: candidate),
              let host = url.host,
              !host.isEmpty,
              !value.contains(" ") else {
            return nil
        }

        if hasScheme {
            return ["http", "https"].contains(url.scheme?.lowercased() ?? "") ? url : nil
        }

        let looksLikeHost = host.contains(".") || host == "localhost" || host == "127.0.0.1"
        return looksLikeHost ? url : nil
    }
}
