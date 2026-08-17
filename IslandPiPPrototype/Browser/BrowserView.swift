import SwiftUI
import WebKit
import UIKit

struct BrowserWebView: UIViewRepresentable {
    @EnvironmentObject private var state: BrowserState

    func makeCoordinator() -> Coordinator { Coordinator(state: state) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let web = WKWebView(frame: .zero, configuration: config)
        web.allowsBackForwardNavigationGestures = true
        web.navigationDelegate = context.coordinator
        web.scrollView.keyboardDismissMode = .interactive
        web.scrollView.contentInsetAdjustmentBehavior = .automatic
        web.isOpaque = false
        web.backgroundColor = .systemBackground
        context.coordinator.web = web

        NotificationCenter.default.addObserver(forName: .browserNavigate, object: nil, queue: .main) { [weak web] note in
            if let url = note.object as? URL { web?.load(URLRequest(url: url)) }
        }
        NotificationCenter.default.addObserver(forName: .browserReload, object: nil, queue: .main) { [weak web] _ in web?.reload() }
        NotificationCenter.default.addObserver(forName: .browserBack, object: nil, queue: .main) { [weak web] _ in web?.goBack() }
        NotificationCenter.default.addObserver(forName: .browserForward, object: nil, queue: .main) { [weak web] _ in web?.goForward() }

        if let initialURL = state.url {
            web.load(URLRequest(url: initialURL))
        }

        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var web: WKWebView?
        let state: BrowserState
        private var observation: NSKeyValueObservation?

        init(state: BrowserState) {
            self.state = state
            super.init()
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            state.isLoading = true
            state.errorMessage = nil
            observation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] web, _ in
                Task { @MainActor in
                    self?.state.progress = web.estimatedProgress
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            state.isLoading = false
            state.url = webView.url
            state.addressText = webView.url?.absoluteString ?? ""
            state.title = webView.title ?? ""
            state.canGoBack = webView.canGoBack
            state.canGoForward = webView.canGoForward
            observation?.invalidate()
            observation = nil
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            state.isLoading = false
            if (error as NSError).code != NSURLErrorCancelled { state.errorMessage = error.localizedDescription }
            observation?.invalidate()
            observation = nil
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            state.isLoading = false
            if (error as NSError).code != NSURLErrorCancelled { state.errorMessage = error.localizedDescription }
            observation?.invalidate()
            observation = nil
        }
    }
}
