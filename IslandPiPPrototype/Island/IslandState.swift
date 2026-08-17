import Combine
import SwiftUI

@MainActor
final class IslandState: ObservableObject {
    @Published private(set) var mode: IslandMode = .collapsed
    @Published var content = IslandDemoFactory.content(for: .music)
    @Published var haptics: Bool = true

    private var collapseTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var timerStartedAt: Date?

    deinit {
        collapseTask?.cancel()
        timerTask?.cancel()
    }

    // MARK: - Public API

    func expand() {
        setMode(.expanded)
    }

    func collapse() {
        setMode(.collapsed)
    }

    func toggle() {
        setMode(mode == .collapsed ? .expanded : .collapsed)
    }

    func showDemo(_ kind: IslandContentKind, expanded: Bool = true) {
        content = IslandDemoFactory.content(for: kind)
        startDemoIfNeeded()
        setMode(expanded ? .expanded : .collapsed)
    }

    func setMode(_ newMode: IslandMode) {
        collapseTask?.cancel()
        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
            mode = newMode
        }
        Haptics.impact(enabled: haptics)
    }

    func dismiss() {
        collapseTask?.cancel()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            mode = .collapsed
        }
    }

    func togglePlayback() {
        content.isPlaying.toggle()
        if content.kind == .timer {
            if content.isPlaying {
                startTimerTicker()
            } else {
                timerTask?.cancel()
            }
        }
        Haptics.impact(enabled: haptics)
    }

    func updateCustomContent(title: String, subtitle: String, icon: String, progress: Double, expanded: Bool) {
        content = IslandContent(
            kind: .custom, title: title, subtitle: subtitle,
            icon: icon, progress: progress, isPlaying: true, accent: .pink
        )
        setMode(expanded ? .expanded : .collapsed)
    }

    // MARK: - Timer demo

    private func startDemoIfNeeded() {
        timerTask?.cancel()
        guard content.kind == .timer else { return }
        timerStartedAt = .now
        startTimerTicker()
    }

    private func startTimerTicker() {
        let total = content.duration ?? 0
        guard total > 0 else { return }
        let baseline = timerStartedAt ?? .now
        timerStartedAt = baseline
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                let remaining = TimerMath.remaining(total: total, startedAt: baseline)
                self.content.progress = TimerMath.progress(total: total, remaining: remaining)
                self.content.subtitle = remaining > 0
                    ? "\(Int(remaining) / 60):\(String(format: "%02d", Int(remaining) % 60)) remaining"
                    : "Complete"
                if remaining == 0 {
                    self.content.isPlaying = false
                    Haptics.impact(enabled: self.haptics)
                    return
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
}
