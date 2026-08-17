import AVFoundation
import AVKit
import Combine
import SwiftUI
import UIKit

@MainActor
final class PiPController: NSObject, ObservableObject {
    @Published private(set) var isPossible = false
    @Published private(set) var isActive = false
    @Published private(set) var message: String?
    @Published private(set) var audioSessionConfigured = false
    let playerLayer = AVPlayerLayer()
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var controller: AVPictureInPictureController?
    private var possibilityObservation: NSKeyValueObservation?
    private var configured = false

    func configureIfNeeded() {
        guard !configured else { return }
        configured = true
        guard AVPictureInPictureController.isPictureInPictureSupported() else { message = "Picture in Picture is unavailable on this device or configuration."; return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            audioSessionConfigured = AVAudioSession.sharedInstance().category == .playback
            let url = try PiPVideoAssetFactory.makeTinyBlackMovie()
            let player = AVQueuePlayer()
            let looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
            self.player = player
            self.looper = looper
            playerLayer.player = player
            playerLayer.videoGravity = .resizeAspect
            let pip = AVPictureInPictureController(playerLayer: playerLayer)
            pip.delegate = self
            pip.canStartPictureInPictureAutomaticallyFromInline = true
            pip.requiresLinearPlayback = true
            controller = pip
            possibilityObservation = pip.observe(\.isPictureInPicturePossible, options: [.initial, .new]) { [weak self] controller, _ in
                Task { @MainActor in self?.isPossible = controller.isPictureInPicturePossible }
            }
            player.play()
            message = "Preparing the lightweight PiP media surface…"
        } catch {
            configured = false
            message = "PiP setup failed: \(error.localizedDescription)"
        }
    }
    func start() { configureIfNeeded(); guard let controller, controller.isPictureInPicturePossible else { message = "PiP is not ready. This must be checked on a physical iPhone."; return }; controller.startPictureInPicture() }
    func stop() { controller?.stopPictureInPicture() }
    func hostDidAppear() { isPossible = controller?.isPictureInPicturePossible ?? false }
}

extension PiPController: AVPictureInPictureControllerDelegate {
    nonisolated func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) { Task { @MainActor in self.message = "PiP starting…" } }
    nonisolated func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) { Task { @MainActor in self.isActive = true; self.message = "PiP active. The system owns size, position, and controls." } }
    nonisolated func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) { Task { @MainActor in self.isActive = false; self.message = "PiP could not start: \(error.localizedDescription)" } }
    nonisolated func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) { Task { @MainActor in self.isActive = false; self.message = "PiP stopped by the system or user." } }
    nonisolated func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) { completionHandler(true) }
}

struct PiPPlayerHost: UIViewRepresentable {
    @EnvironmentObject private var pip: PiPController
    func makeUIView(context: Context) -> PiPPlayerHostView { PiPPlayerHostView(layer: pip.playerLayer, onAppear: pip.hostDidAppear) }
    func updateUIView(_ uiView: PiPPlayerHostView, context: Context) { }
}

final class PiPPlayerHostView: UIView {
    private let pipLayer: AVPlayerLayer
    private let appeared: () -> Void
    init(layer: AVPlayerLayer, onAppear: @escaping () -> Void) { self.pipLayer = layer; self.appeared = onAppear; super.init(frame: .zero); self.layer.addSublayer(layer) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() { super.layoutSubviews(); pipLayer.frame = bounds }
    override func didMoveToWindow() { super.didMoveToWindow(); appeared() }
}
