import Foundation

enum DemoFactory {
    static func content(for kind: DemoKind) -> IslandContent {
        switch kind {
        case .music: return IslandContent(kind: kind, title: "After Dark", subtitle: "Mr.Kitty", icon: "music.note", progress: 0.42, isPlaying: true, accent: .purple)
        case .timer: return IslandContent(kind: kind, title: "Focus timer", subtitle: "12:34 remaining", icon: "timer", progress: 0.37, duration: 754, isPlaying: true, accent: .orange)
        case .charging: return IslandContent(kind: kind, title: "Charging", subtitle: "87% • 38 min until full", icon: "bolt.fill", progress: 0.87, isPlaying: true, accent: .green)
        case .battery: return IslandContent(kind: kind, title: "Low Battery", subtitle: "20% remaining", icon: "battery.25", progress: 0.2, isPlaying: false, accent: .red)
        case .notification: return IslandContent(kind: kind, title: "Sample App", subtitle: "Your package is on its way", icon: "bell.badge.fill", progress: nil, isPlaying: false, accent: .blue)
        case .download: return IslandContent(kind: kind, title: "Downloading", subtitle: "Podcast episode", icon: "arrow.down.circle.fill", progress: 0.68, isPlaying: true, accent: .cyan)
        case .custom: return IslandContent(kind: kind, title: "Custom title", subtitle: "Custom subtitle", icon: "sparkles", progress: 0.5, isPlaying: true, accent: .pink)
        }
    }
}

struct TimerMath {
    static func remaining(total: TimeInterval, startedAt: Date, now: Date = .now) -> TimeInterval { max(0, total - now.timeIntervalSince(startedAt)) }
    static func progress(total: TimeInterval, remaining: TimeInterval) -> Double { guard total > 0 else { return 0 }; return min(1, max(0, 1 - remaining / total)) }
}
