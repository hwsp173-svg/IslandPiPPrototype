import SwiftUI

// MARK: - Island Content Model

struct IslandContent: Equatable {
    var kind: IslandContentKind = .music
    var title: String = "After Dark"
    var subtitle: String = "Mr.Kitty"
    var icon: String = "music.note"
    var progress: Double? = 0.42
    var duration: TimeInterval? = nil
    var isPlaying: Bool = true
    var accent: Color = .purple
}

// MARK: - Content kinds

enum IslandContentKind: String, CaseIterable, Identifiable {
    case music, timer, charging, download, notification, custom
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

// MARK: - Island mode

enum IslandMode: String, CaseIterable, Identifiable {
    case collapsed, expanded
    var id: String { rawValue }
}

// MARK: - Demo content factory

enum IslandDemoFactory {
    static func content(for kind: IslandContentKind) -> IslandContent {
        switch kind {
        case .music:
            return IslandContent(kind: kind, title: "After Dark", subtitle: "Mr.Kitty", icon: "music.note", progress: 0.42, isPlaying: true, accent: .purple)
        case .timer:
            return IslandContent(kind: kind, title: "Focus Timer", subtitle: "12:34 remaining", icon: "timer", progress: 0.37, duration: 754, isPlaying: true, accent: .orange)
        case .charging:
            return IslandContent(kind: kind, title: "Charging", subtitle: "87% • 38 min until full", icon: "bolt.fill", progress: 0.87, isPlaying: true, accent: .green)
        case .download:
            return IslandContent(kind: kind, title: "Downloading", subtitle: "Podcast episode", icon: "arrow.down.circle.fill", progress: 0.68, isPlaying: true, accent: .cyan)
        case .notification:
            return IslandContent(kind: kind, title: "Messages", subtitle: "Your package is on its way", icon: "bell.badge.fill", progress: nil, isPlaying: false, accent: .blue)
        case .custom:
            return IslandContent(kind: kind, title: "Custom Title", subtitle: "Custom subtitle", icon: "sparkles", progress: 0.5, isPlaying: true, accent: .pink)
        }
    }
}

// MARK: - Timer math utilities

struct TimerMath {
    static func remaining(total: TimeInterval, startedAt: Date, now: Date = .now) -> TimeInterval {
        max(0, total - now.timeIntervalSince(startedAt))
    }
    static func progress(total: TimeInterval, remaining: TimeInterval) -> Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, 1 - remaining / total))
    }
}
