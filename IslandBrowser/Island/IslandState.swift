import Foundation
import SwiftUI

enum IslandMode: String, CaseIterable, Identifiable {
    case music
    case timer
    case charging
    case download
    case notification
    case custom

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var symbol: String {
        switch self {
        case .music: "music.note"
        case .timer: "timer"
        case .charging: "bolt.fill"
        case .download: "arrow.down.circle.fill"
        case .notification: "bell.fill"
        case .custom: "sparkles"
        }
    }

    var tint: Color {
        switch self {
        case .music: .pink
        case .timer: .orange
        case .charging: .green
        case .download: .blue
        case .notification: .purple
        case .custom: .cyan
        }
    }
}

@MainActor
final class IslandState: ObservableObject {
    @Published var mode: IslandMode = .music
    @Published var isExpanded = false
    @Published var settingsPresented = false

    @Published var customTitle = "IslandBrowser"
    @Published var customSubtitle = "Ready when you are"
    @Published var customSymbol = "sparkles"

    @Published private(set) var isMusicPlaying = true
    @Published private(set) var musicProgress = 0.42

    let timerDuration = 92
    @Published private(set) var timerRemaining = 92
    @Published private(set) var isTimerRunning = false

    @Published var batteryLevel = 0.87
    @Published var isCharging = true

    @Published private(set) var downloadProgress = 0.68
    @Published private(set) var downloadFilename = "IslandBrowser-release.ipa"

    @Published private(set) var notificationTitle = "Reading list updated"
    @Published private(set) var notificationSubtitle = "3 new links are ready"

    private var timer: Timer?
    private var downloadTimer: Timer?
    private var notificationDismissTask: Task<Void, Never>?

    deinit {
        timer?.invalidate()
        downloadTimer?.invalidate()
        notificationDismissTask?.cancel()
    }

    func expand() {
        Haptics.light()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
            isExpanded = true
        }
    }

    func collapse() {
        Haptics.light()
        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            isExpanded = false
        }
    }

    func toggleExpanded() {
        isExpanded ? collapse() : expand()
    }

    func setMode(_ mode: IslandMode) {
        self.mode = mode
        if mode == .timer && timerRemaining == 0 {
            resetTimer()
        }
        if mode == .download {
            startDownloadDemo()
        }
        if mode == .notification {
            showNotification()
        }
    }

    func toggleMusic() {
        isMusicPlaying.toggle()
        Haptics.light()
    }

    func skipMusic(by amount: Double) {
        musicProgress = min(max(musicProgress + amount, 0), 1)
        Haptics.light()
    }

    func toggleTimer() {
        isTimerRunning ? pauseTimer() : startTimer()
    }

    func startTimer() {
        guard timerRemaining > 0 else { return }
        timer?.invalidate()
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tickTimer()
        }
    }

    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    func resetTimer() {
        pauseTimer()
        timerRemaining = timerDuration
    }

    func showNotification(title: String = "Reading list updated", subtitle: String = "3 new links are ready") {
        notificationTitle = title
        notificationSubtitle = subtitle
        mode = .notification
        notificationDismissTask?.cancel()
        Haptics.success()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            isExpanded = true
        }
        notificationDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.collapse()
            }
        }
    }

    private func tickTimer() {
        guard timerRemaining > 0 else {
            pauseTimer()
            Haptics.success()
            return
        }

        timerRemaining -= 1
        if timerRemaining == 0 {
            pauseTimer()
            Haptics.success()
        }
    }

    private func startDownloadDemo() {
        if downloadProgress >= 1 {
            downloadProgress = 0.08
        }
        downloadTimer?.invalidate()
        downloadTimer = Timer.scheduledTimer(withTimeInterval: 0.16, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.downloadProgress = min(self.downloadProgress + 0.035, 1)
            if self.downloadProgress >= 1 {
                timer.invalidate()
            }
        }
    }

    func restartDownload() {
        downloadProgress = 0.08
        startDownloadDemo()
    }

    var timerProgress: Double {
        1 - (Double(timerRemaining) / Double(timerDuration))
    }

    var timerText: String {
        let minutes = timerRemaining / 60
        let seconds = timerRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var collapsedTitle: String {
        switch mode {
        case .music: "Now playing"
        case .timer: timerText
        case .charging: "Charging"
        case .download: "Downloading"
        case .notification: notificationTitle
        case .custom: customTitle
        }
    }

    var collapsedSubtitle: String {
        switch mode {
        case .music: "Midnight City · M83"
        case .timer: "Timer"
        case .charging: "\(Int(batteryLevel * 100))% · Connected"
        case .download: "\(Int(downloadProgress * 100))% complete"
        case .notification: notificationSubtitle
        case .custom: customSubtitle
        }
    }

    var collapsedSymbol: String {
        mode == .custom ? customSymbol : mode.symbol
    }
}
