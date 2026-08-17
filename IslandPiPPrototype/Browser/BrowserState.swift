import Foundation
import SwiftUI

@MainActor
final class BrowserState: ObservableObject {
    @Published var url: URL?
    @Published var title = ""
    @Published var addressText = ""
    @Published var isLoading = false
    @Published var progress = 0.0
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var showingHome = true
    @Published var isFullscreen = false
    @Published var errorMessage: String?

    func navigate(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let target: URL?
        if let direct = URL(string: trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") ? trimmed : "https://" + trimmed),
           direct.host != nil, trimmed.contains(".") {
            target = direct
        } else {
            let query = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            target = URL(string: "https://www.google.com/search?q=\(query)")
        }
        
        guard let target else { return }
        url = target
        addressText = target.absoluteString
        showingHome = false
        errorMessage = nil
        NotificationCenter.default.post(name: .browserNavigate, object: target)
    }

    func reload() { NotificationCenter.default.post(name: .browserReload, object: nil) }
    func goBack() { NotificationCenter.default.post(name: .browserBack, object: nil) }
    func goForward() { NotificationCenter.default.post(name: .browserForward, object: nil) }
    func toggleFullscreen() { isFullscreen.toggle() }
    func goHome() { showingHome = true; addressText = "" }
}

extension Notification.Name {
    static let browserNavigate = Notification.Name("IslandBrowser.navigate")
    static let browserReload = Notification.Name("IslandBrowser.reload")
    static let browserBack = Notification.Name("IslandBrowser.back")
    static let browserForward = Notification.Name("IslandBrowser.forward")
}
