import Combine
import SwiftUI

@MainActor
final class IslandController: ObservableObject {
    @Published private(set) var mode: IslandMode = .collapsed
    @Published var content = DemoFactory.content(for: .music)
    @Published var settings = IslandSettings()
    private var collapseTask: Task<Void, Never>?
    private var demoTask: Task<Void, Never>?
    private var timerStartedAt: Date?

    deinit { collapseTask?.cancel(); demoTask?.cancel() }

    func show(_ kind: DemoKind, expanded: Bool = true) { content = DemoFactory.content(for: kind); startDemoIfNeeded(); setMode(expanded ? .expanded : .collapsed) }
    func toggle() { setMode(mode == .collapsed ? .expanded : .collapsed) }
    func setMode(_ newMode: IslandMode) {
        collapseTask?.cancel()
        withAnimation(settings.reduceMotion ? .easeInOut(duration: 0.18) : .spring(response: 0.42 / settings.animationSpeed, dampingFraction: 0.82)) { mode = newMode }
        Haptics.impact(enabled: settings.haptics)
        if newMode == .expanded, settings.autoCollapse > 0 {
            let delay = settings.autoCollapse
            collapseTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await self?.collapse()
            }
        }
    }
    func collapse() { setMode(.collapsed) }
    func dismiss() { collapseTask?.cancel(); withAnimation { mode = .collapsed } }
    func togglePlayback() { content.isPlaying.toggle(); if content.kind == .timer { content.isPlaying ? startTimerTicker() : demoTask?.cancel() }; Haptics.impact(enabled: settings.haptics) }

    private func startDemoIfNeeded() { demoTask?.cancel(); guard content.kind == .timer else { return }; timerStartedAt = .now; startTimerTicker() }
    private func startTimerTicker() {
        let total = content.duration ?? 0
        guard total > 0 else { return }
        let baseline = timerStartedAt ?? .now
        timerStartedAt = baseline
        demoTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                let remaining = TimerMath.remaining(total: total, startedAt: baseline)
                self.content.progress = TimerMath.progress(total: total, remaining: remaining)
                self.content.subtitle = remaining > 0 ? "\(Int(remaining) / 60):\(String(format: "%02d", Int(remaining) % 60)) remaining" : "Complete"
                if remaining == 0 { self.content.isPlaying = false; Haptics.impact(enabled: self.settings.haptics); return }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
}
