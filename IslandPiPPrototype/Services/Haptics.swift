import UIKit

enum Haptics {
    static func impact(enabled: Bool, style: UIImpactFeedbackGenerator.FeedbackStyle = .soft) {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func notification(enabled: Bool, type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
