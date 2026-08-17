import SwiftUI

struct DynamicIslandOverlay: View {
    @EnvironmentObject private var islandState: IslandState
    @Namespace private var islandNamespace

    var body: some View {
        let expanded = islandState.mode == .expanded
        ZStack {
            // Dimmed background when expanded – tapping collapses
            if expanded {
                Color.black.opacity(0.001) // Nearly invisible but captures taps
                    .ignoresSafeArea()
                    .onTapGesture {
                        islandState.collapse()
                    }
            }

            VStack {
                islandPill
                    .padding(.top, islandTopPadding)
                Spacer()
            }
        }
        .allowsHitTesting(true)
    }

    // MARK: - Top padding calculation
    /// On iPhone 12 the status bar region is ~47pt. We position
    /// the pill so it sits within the notch/safe-area region.
    private var islandTopPadding: CGFloat {
        4
    }

    // MARK: - The pill
    private var islandPill: some View {
        let expanded = islandState.mode == .expanded

        return Group {
            if expanded {
                expandedIsland
            } else {
                collapsedIsland
            }
        }
        .frame(
            width: expanded ? 340 : 126,
            height: expanded ? nil : 36
        )
        .background(islandBackground)
        .clipShape(RoundedRectangle(cornerRadius: expanded ? 32 : 18, style: .continuous))
        .shadow(color: .black.opacity(0.55), radius: expanded ? 24 : 10, y: expanded ? 10 : 4)
        .onTapGesture {
            if !expanded {
                islandState.expand()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.height < -20 {
                        islandState.dismiss()
                    }
                }
        )
        .animation(
            .spring(response: 0.42, dampingFraction: 0.82),
            value: islandState.mode
        )
    }

    private var islandBackground: some ShapeStyle {
        Color.black
    }

    // MARK: - Collapsed
    private var collapsedIsland: some View {
        HStack(spacing: 8) {
            Image(systemName: islandState.content.icon)
                .foregroundStyle(islandState.content.accent)
                .font(.system(size: 12, weight: .bold))

            if islandState.content.isPlaying && islandState.content.kind == .music {
                EqualizerBars(color: islandState.content.accent)
            }

            Spacer(minLength: 0)

            if let progress = islandState.content.progress {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .medium, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(.horizontal, 14)
    }

    // MARK: - Expanded
    private var expandedIsland: some View {
        VStack(spacing: 12) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: islandState.content.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(islandState.content.accent)
                    .frame(width: 34, height: 34)
                    .background(
                        islandState.content.accent.opacity(0.18),
                        in: RoundedRectangle(cornerRadius: 9, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(islandState.content.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(islandState.content.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }

                Spacer()
            }

            // Progress bar
            if let progress = islandState.content.progress {
                ProgressView(value: progress)
                    .tint(islandState.content.accent)
                    .scaleEffect(y: 0.6)
            }

            // Controls
            expandedControls
        }
        .padding(18)
    }

    @ViewBuilder
    private var expandedControls: some View {
        switch islandState.content.kind {
        case .music:
            musicControls
        case .timer:
            timerControls
        case .charging:
            chargingInfo
        case .download:
            downloadInfo
        case .notification:
            notificationInfo
        case .custom:
            customInfo
        }
    }

    private var musicControls: some View {
        HStack(spacing: 30) {
            Button { } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 16))
            }
            Button { islandState.togglePlayback() } label: {
                Image(systemName: islandState.content.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .background(islandState.content.accent, in: Circle())
            }
            Button { } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 16))
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
    }

    private var timerControls: some View {
        HStack(spacing: 20) {
            Button {
                islandState.togglePlayback()
            } label: {
                Image(systemName: islandState.content.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 32, height: 32)
                    .background(islandState.content.accent, in: Circle())
            }
            Button {
                islandState.showDemo(.timer, expanded: true)
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.15), in: Circle())
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
    }

    private var chargingInfo: some View {
        HStack {
            Image(systemName: "bolt.fill")
                .foregroundStyle(.green)
                .font(.system(size: 14))
            Text("Estimated time until full: 38 min")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var downloadInfo: some View {
        HStack {
            Image(systemName: "arrow.down")
                .foregroundStyle(islandState.content.accent)
                .font(.system(size: 14))
            Text("Downloading… \(Int((islandState.content.progress ?? 0) * 100))%")
                .font(.system(size: 12, design: .rounded).monospacedDigit())
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var notificationInfo: some View {
        Button {
            islandState.collapse()
        } label: {
            Text("Dismiss")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var customInfo: some View {
        Text("Custom island content")
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.5))
    }
}

// MARK: - Equalizer Bars

private struct EqualizerBars: View {
    let color: Color
    @State private var active = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(color)
                    .frame(width: 2, height: active ? CGFloat(6 + index * 3) : 3)
                    .animation(
                        .easeInOut(duration: 0.35)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.08),
                        value: active
                    )
            }
        }
        .onAppear { active = true }
    }
}
