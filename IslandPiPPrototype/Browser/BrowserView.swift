import SwiftUI
import WebKit

// MARK: - WKWebView UIKit wrapper

struct BrowserWebView: UIViewRepresentable {
    @EnvironmentObject private var browserState: BrowserState

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = [.all]

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        // Set user agent to something sensible so mobile sites work
        webView.customUserAgent = nil // use default WebKit UA

        context.coordinator.webView = webView
        context.coordinator.browserState = browserState
        browserState.webView = webView

        // Observe properties
        context.coordinator.observe(webView)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.browserState = browserState
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?
        weak var browserState: BrowserState?

        private var titleObserver: NSKeyValueObservation?
        private var urlObserver: NSKeyValueObservation?
        private var canGoBackObserver: NSKeyValueObservation?
        private var canGoForwardObserver: NSKeyValueObservation?
        private var loadingObserver: NSKeyValueObservation?
        private var progressObserver: NSKeyValueObservation?

        func observe(_ webView: WKWebView) {
            webView.navigationDelegate = self

            titleObserver = webView.observe(\.title, options: [.new]) { [weak self] wv, _ in
                Task { @MainActor in self?.browserState?.pageTitle = wv.title ?? "" }
            }
            urlObserver = webView.observe(\.url, options: [.new]) { [weak self] wv, _ in
                Task { @MainActor in
                    self?.browserState?.currentURL = wv.url
                    if let url = wv.url, url.absoluteString != "about:blank" {
                        self?.browserState?.urlString = url.absoluteString
                    }
                }
            }
            canGoBackObserver = webView.observe(\.canGoBack, options: [.new]) { [weak self] wv, _ in
                Task { @MainActor in self?.browserState?.canGoBack = wv.canGoBack }
            }
            canGoForwardObserver = webView.observe(\.canGoForward, options: [.new]) { [weak self] wv, _ in
                Task { @MainActor in self?.browserState?.canGoForward = wv.canGoForward }
            }
            loadingObserver = webView.observe(\.isLoading, options: [.new]) { [weak self] wv, _ in
                Task { @MainActor in self?.browserState?.isLoading = wv.isLoading }
            }
            progressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] wv, _ in
                Task { @MainActor in self?.browserState?.loadingProgress = wv.estimatedProgress }
            }
        }

        // MARK: WKNavigationDelegate
        nonisolated func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in browserState?.errorMessage = nil }
        }

        nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                browserState?.isLoading = false
                browserState?.showingHome = false
            }
        }

        nonisolated func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                let nsError = error as NSError
                // Don't show error for user-cancelled navigations
                if nsError.code == NSURLErrorCancelled { return }
                browserState?.errorMessage = error.localizedDescription
                browserState?.isLoading = false
            }
        }

        nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                let nsError = error as NSError
                if nsError.code == NSURLErrorCancelled { return }
                browserState?.errorMessage = error.localizedDescription
                browserState?.isLoading = false
            }
        }

        nonisolated func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            // Allow all standard navigations
            return .allow
        }
    }
}
