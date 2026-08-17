import SwiftUI
import WebKit
import UIKit

struct BrowserWebView: UIViewRepresentable {
    @ObservedObject var state: BrowserState

    func makeCoordinator() -> Coordinator { Coordinator(state: state) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.allowsInlineMediaPlayback = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        let web = WKWebView(frame: .zero, configuration: config)
        web.allowsBackForwardNavigationGestures = true
        web.navigationDelegate = context.coordinator
        web.uiDelegate = context.coordinator
        web.scrollView.keyboardDismissMode = .interactive
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.backgroundColor = .systemBackground
        web.isOpaque = false
        context.coordinator.web = web
        context.coordinator.progressObservation = web.observe(\WKWebView.estimatedProgress, options: [.initial, .new]) { [weak state] webView, _ in
            let value = webView.estimatedProgress
            Task { @MainActor in state?.updateProgress(value) }
        }
        state.attach(webView: web)

        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        weak var web: WKWebView?
        let state: BrowserState
        var progressObservation: NSKeyValueObservation?

        init(state: BrowserState) { self.state = state }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in state.navigationDidStart(for: webView) }
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            let url = webView.url
            Task { @MainActor in
                if let url { state.addressText = url.absoluteString }
                state.updateNavigationState(from: webView)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in state.navigationDidFinish(for: webView) }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in state.navigationDidFail(for: webView, error: error) }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in state.navigationDidFail(for: webView, error: error) }
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: webView.title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
            present(alert, from: webView, completionHandler: completionHandler)
        }

        private func present(_ alert: UIAlertController, from view: UIView, completionHandler: @escaping () -> Void) {
            guard let presenter = view.window?.rootViewController else {
                completionHandler()
                return
            }
            var visible = presenter
            while let presented = visible.presentedViewController { visible = presented }
            visible.present(alert, animated: true)
        }
    }
}
