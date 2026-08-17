import SwiftUI
import UIKit

enum IslandMode: String, CaseIterable, Identifiable {
    case music, timer, charging, download, notification, custom
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .music: return "Now Playing"
        case .timer: return "Focus Timer"
        case .charging: return "Charging"
        case .download: return "Downloading"
        case .notification: return "Notification"
        case .custom: return "Custom Demo"
        }
    }
}

@MainActor
final class IslandState: ObservableObject {
    @Published var mode: IslandMode = .music
    @Published var expanded = false
    @Published var isPlaying = true
    @Published var customTitle = "IslandBrowser"
    @Published var customSubtitle = "Ready"
    @Published var progressValue = 0.68

    func nextMode() {
        let all = IslandMode.allCases
        if let i = all.firstIndex(of: mode) {
            mode = all[(i + 1) % all.count]
        }
    }

    func previousMode() {
        let all = IslandMode.allCases
        if let i = all.firstIndex(of: mode) {
            mode = all[(i - 1 + all.count) % all.count]
        }
    }

    func cycle() { nextMode() }
}
