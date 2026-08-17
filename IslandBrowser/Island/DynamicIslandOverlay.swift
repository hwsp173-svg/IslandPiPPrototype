import SwiftUI

struct DynamicIslandOverlay: View {
    @EnvironmentObject private var island: IslandState
    let topSafeArea: CGFloat
    let containerWidth: CGFloat

    private var expandedWidth: CGFloat {
        min(356, max(280, containerWidth - 24))
    }

    private var compactWidth: CGFloat {
        min(156, max(128, containerWidth - 48))
    }

    private var surfaceSize: CGSize {
        if island.isExpanded {
            return CGSize(width: expandedWidth, height: 310)
        }
        return CGSize(width: compactWidth, height: 38)
    }

    var body: some View {
        IslandPassthroughHost(
            topInset: max(topSafeArea, 0) + 6,
            surfaceSize: surfaceSize,
            content: IslandSurface(island: island, expandedWidth: expandedWidth, compactWidth: compactWidth)
        )
        .frame(maxWidth: .infinity)
        .frame(height: max(topSafeArea, 0) + surfaceSize.height + 18)
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: island.isExpanded)
        .accessibilityElement(children: .contain)
    }
}

private struct IslandSurface: View {
    @ObservedObject var island: IslandState
    let expandedWidth: CGFloat
    let compactWidth: CGFloat
    @Namespace private var islandNamespace

    var body: some View {
        Group {
            if island.isExpanded {
                ExpandedIsland(island: island, namespace: islandNamespace, width: expandedWidth)
            } else {
                CollapsedIsland(island: island, namespace: islandNamespace, width: compactWidth)
            }
        }
        .frame(width: island.isExpanded ? expandedWidth : compactWidth, height: island.isExpanded ? 310 : 38)
        .contentShape(RoundedRectangle(cornerRadius: island.isExpanded ? 30 : 22, style: .continuous))
        .simultaneousGesture(
            DragGesture(minimumDistance: 10).onEnded { value in
                if island.isExpanded && value.translation.height < -18 {
                    island.collapse()
                }
            }
        )
    }
}

private struct CollapsedIsland: View {
    @ObservedObject var island: IslandState
    let namespace: Namespace.ID
    let width: CGFloat

    var body: some View {
        Button {
            island.expand()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: island.collapsedSymbol)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(island.mode.tint)
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: 1) {
                    Text(island.collapsedTitle)
                        .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(island.collapsedSubtitle)
                        .font(.system(size: 9.5, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                        .lineLimit(1)
                }

                if island.mode == .music && island.isMusicPlaying {
                    WaveformMark()
                        .frame(width: 18, height: 18)
                }
            }
            .padding(.horizontal, 12)
            .frame(width: width, height: 38)
            .background(.black, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.08), lineWidth: 0.6)
            }
            .shadow(color: .black.opacity(0.32), radius: 12, y: 5)
            .matchedGeometryEffect(id: "island-surface", in: namespace)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Expand Dynamic Island")
    }
}

private struct ExpandedIsland: View {
    @ObservedObject var island: IslandState
    let namespace: Namespace.ID
    let width: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: island.collapsedSymbol)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(island.mode.tint)
                    .frame(width: 28, height: 28)
                    .background(island.mode.tint.opacity(0.16), in: Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text(island.collapsedTitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(island.collapsedSubtitle)
                        .font(.system(size: 10.5, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                Button {
                    island.settingsPresented = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Island settings")

                Button {
                    island.collapse()
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Collapse Dynamic Island")
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            Divider().overlay(.white.opacity(0.08))

            modeContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(16)
        }
        .frame(width: width, height: 310)
        .background(.black, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 0.7)
        }
        .shadow(color: .black.opacity(0.42), radius: 24, y: 10)
        .matchedGeometryEffect(id: "island-surface", in: namespace)
        .transition(.asymmetric(insertion: .scale(scale: 0.78, anchor: .top).combined(with: .opacity), removal: .scale(scale: 0.78, anchor: .top).combined(with: .opacity)))
    }

    @ViewBuilder
    private var modeContent: some View {
        switch island.mode {
        case .music:
            MusicIslandContent(island: island)
        case .timer:
            TimerIslandContent(island: island)
        case .charging:
            ChargingIslandContent(island: island)
        case .download:
            DownloadIslandContent(island: island)
        case .notification:
            NotificationIslandContent(island: island)
        case .custom:
            CustomIslandContent(island: island)
        }
    }
}

private struct MusicIslandContent: View {
    @ObservedObject var island: IslandState

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                    Image(systemName: "waveform")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.pink)
                }
                .frame(width: 62, height: 62)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Midnight City")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("M83 · Hurry Up, We're Dreaming")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                        .lineLimit(1)
                }
                Spacer()
            }

            ProgressView(value: island.musicProgress)
                .tint(.white)

            HStack {
                Text("1:42")
                Spacer()
                Text("4:03")
            }
            .font(.system(size: 9, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.46))

            HStack(spacing: 28) {
                IslandAction(systemName: "backward.fill", label: "Previous") {
                    island.skipMusic(by: -0.12)
                }
                IslandAction(systemName: island.isMusicPlaying ? "pause.fill" : "play.fill", label: island.isMusicPlaying ? "Pause" : "Play") {
                    island.toggleMusic()
                }
                IslandAction(systemName: "forward.fill", label: "Next") {
                    island.skipMusic(by: 0.12)
                }
            }
        }
    }
}

private struct TimerIslandContent: View {
    @ObservedObject var island: IslandState

    var body: some View {
        VStack(spacing: 16) {
            Text(island.timerText)
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)

            ProgressView(value: island.timerProgress)
                .tint(.orange)

            Text(island.isTimerRunning ? "Counting down" : "Paused")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))

            HStack(spacing: 12) {
                IslandAction(systemName: island.isTimerRunning ? "pause.fill" : "play.fill", label: island.isTimerRunning ? "Pause" : "Start") {
                    island.toggleTimer()
                }
                IslandAction(systemName: "arrow.counterclockwise", label: "Reset") {
                    island.resetTimer()
                }
            }
        }
    }
}

private struct ChargingIslandContent: View {
    @ObservedObject var island: IslandState

    var body: some View {
        VStack(spacing: 17) {
            HStack(spacing: 12) {
                Image(systemName: "battery.100percent.bolt")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Charging")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("Power connected")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer()
            }
            .foregroundStyle(.white)

            ProgressView(value: island.batteryLevel)
                .tint(.green)

            HStack(alignment: .firstTextBaseline) {
                Text("\(Int(island.batteryLevel * 100))%")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Spacer()
                Text("Full in 38 min")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
    }
}

private struct DownloadIslandContent: View {
    @ObservedObject var island: IslandState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: island.downloadProgress >= 1 ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 3) {
                    Text(island.downloadProgress >= 1 ? "Download complete" : "Downloading")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                    Text(island.downloadFilename)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }
                Spacer()
            }

            ProgressView(value: island.downloadProgress)
                .tint(.blue)

            HStack {
                Text("\(Int(island.downloadProgress * 100))%")
                    .font(.system(size: 29, weight: .bold, design: .rounded))
                Spacer()
                if island.downloadProgress >= 1 {
                    Button("Download again") {
                        island.restartDownload()
                    }
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                } else {
                    Text("Preparing file")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }
            .foregroundStyle(.white)
        }
    }
}

private struct NotificationIslandContent: View {
    @ObservedObject var island: IslandState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundStyle(.purple)
                    .frame(width: 48, height: 48)
                    .background(.purple.opacity(0.15), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text("IslandBrowser")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                    Text(island.notificationTitle)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }

            Text(island.notificationSubtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))

            Button {
                island.collapse()
            } label: {
                Text("Dismiss")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
        }
    }
}

private struct CustomIslandContent: View {
    @ObservedObject var island: IslandState

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: island.customSymbol)
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(.cyan)
            Text(island.customTitle)
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(island.customSubtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.58))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct IslandAction: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.1), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct WaveformMark: View {
    @State private var phase = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(0.76))
                    .frame(width: 2.5, height: phase ? CGFloat(5 + index * 3) : CGFloat(10 - index))
            }
        }
        .animation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true), value: phase)
        .onAppear { phase = true }
    }
}
