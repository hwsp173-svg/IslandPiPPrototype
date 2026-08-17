import UIKit

enum Haptics {
    static func impact(enabled: Bool) { guard enabled else { return }; UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
}
