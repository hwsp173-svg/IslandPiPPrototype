import SwiftUI

enum IslandMode: String, CaseIterable, Identifiable { case collapsed, expanded; var id: String { rawValue } }
enum DemoKind: String, CaseIterable, Identifiable { case music, timer, charging, battery, notification, download, custom; var id: String { rawValue }; var label: String { rawValue.capitalized } }

struct IslandContent: Equatable {
    var kind: DemoKind = .music
    var title = "After Dark"
    var subtitle = "Mr.Kitty"
    var icon = "music.note"
    var progress: Double? = 0.42
    var duration: TimeInterval? = nil
    var isPlaying = true
    var accent: Color = .purple
}

struct IslandSettings {
    var isEnabled = true
    var demoMode = true
    var animationSpeed = 1.0
    var autoCollapse = 5.0
    var scale = 1.0
    var cornerRadius = 24.0
    var opacity = 1.0
    var haptics = true
    var reduceMotion = false
}
