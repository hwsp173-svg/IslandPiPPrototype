import SwiftUI
import UIKit

struct IslandPassthroughHost<Content: View>: UIViewRepresentable {
    let topInset: CGFloat
    let surfaceSize: CGSize
    let content: Content

    func makeUIView(context: Context) -> IslandPassthroughView {
        let container = IslandPassthroughView()
        container.topInset = topInset
        container.surfaceSize = surfaceSize

        let hostingController = UIHostingController(rootView: AnyView(content))
        hostingController.view.backgroundColor = .clear
        hostingController.view.isUserInteractionEnabled = true
        container.hostingController = hostingController
        container.addSubview(hostingController.view)
        return container
    }

    func updateUIView(_ uiView: IslandPassthroughView, context: Context) {
        uiView.topInset = topInset
        uiView.surfaceSize = surfaceSize
        uiView.hostingController?.rootView = AnyView(content)
        uiView.setNeedsLayout()
    }
}

final class IslandPassthroughView: UIView {
    var topInset: CGFloat = 0
    var surfaceSize: CGSize = .zero
    var hostingController: UIHostingController<AnyView>?

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let hostingView = hostingController?.view else { return }
        hostingView.frame = CGRect(
            x: (bounds.width - surfaceSize.width) / 2,
            y: topInset,
            width: surfaceSize.width,
            height: surfaceSize.height
        )
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hostingView = hostingController?.view else { return nil }
        let localPoint = convert(point, to: hostingView)
        guard hostingView.bounds.contains(localPoint) else { return nil }

        let hitView = hostingView.hitTest(localPoint, with: event)
        return hitView === hostingView ? nil : hitView
    }
}
