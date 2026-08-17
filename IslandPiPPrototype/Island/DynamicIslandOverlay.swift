import SwiftUI

struct DynamicIslandOverlay: View {
    @EnvironmentObject private var island: IslandState

    var body: some View {
        GeometryReader { proxy in
            let topInset = max(proxy.safeAreaInsets.top, 11)
            
            VStack(spacing: 0) {
                if island.expanded {
                    expandedIsland
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .scale(scale: 0.85).combined(with: .opacity)
                        ))
                } else {
                    collapsedIsland
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.top, topInset + 2)
            .animation(.spring(response: 0.36, dampingFraction: 0.82), value: island.expanded)
        }
        .allowsHitTesting(false)
    }

    private var collapsedIsland: some View {
        Button {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                island.expanded = true
            }
            Haptics.light()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(accentColor)
                
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Spacer(minLength: 2)
                
                indicatorView
            }
            .padding(.horizontal, 14)
            .frame(height: 37)
            .background(Color.black, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(true)
    }

    private var expandedIsland: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(accentColor)
                    .frame(width: 36, height: 36)
                    .background(accentColor.opacity(0.18), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                        island.expanded = false
                    }
                    Haptics.light()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
            }
            
            if island.mode == .download || island.mode == .timer || island.mode == .charging {
                ProgressView(value: island.progressValue)
                    .tint(accentColor)
                    .padding(.horizontal, 2)
            }

            Divider().overlay(Color.white.opacity(0.1))

            HStack(spacing: 10) {
                actionBtn(icon: "chevron.left", text: "Prev") {
                    island.previousMode()
                    Haptics.medium()
                }
                actionBtn(icon: island.isPlaying ? "pause.fill" : "play.fill", text: island.isPlaying ? "Pause" : "Play") {
                    island.isPlaying.toggle()
                    Haptics.medium()
                }
                actionBtn(icon: "chevron.right", text: "Next") {
                    island.nextMode()
                    Haptics.medium()
                }
            }
        }
        .padding(14)
        .frame(width: min(UIScreen.main.bounds.width - 28, 360))
        .background(Color.black, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.55), radius: 18, x: 0, y: 8)
        .allowsHitTesting(true)
    }

    private func actionBtn(icon: String, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(text)
                    .font(.system(size: 10, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var indicatorView: some View {
        switch island.mode {
        case .music:
            EqualizerView(color: accentColor)
        case .timer:
            Text("1:32")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(accentColor)
        case .charging:
            Image(systemName: "bolt.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.green)
        case .download:
            Text("\(Int(island.progressValue * 100))%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(accentColor)
        case .notification:
            Circle()
                .fill(.blue)
                .frame(width: 7, height: 7)
        case .custom:
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.pink)
        }
    }

    private var label: String {
        switch island.mode {
        case .music: return "After Dark"
        case .timer: return "Focus Timer"
        case .charging: return "Charging"
        case .download: return "Downloading"
        case .notification: return "IslandBrowser"
        case .custom: return island.customTitle
        }
    }

    private var subtitle: String {
        switch island.mode {
        case .music: return "Mr.Kitty • Synthwave"
        case .timer: return "1:32 remaining"
        case .charging: return "87% • 22 min until full"
        case .download: return "\(Int(island.progressValue * 100))% • Podcast episode"
        case .notification: return "New tab loaded in background"
        case .custom: return island.customSubtitle
        }
    }

    private var iconName: String {
        switch island.mode {
        case .music: return "music.note"
        case .timer: return "timer"
        case .charging: return "bolt.fill"
        case .download: return "arrow.down.circle.fill"
        case .notification: return "bell.fill"
        case .custom: return "sparkles"
        }
    }

    private var accentColor: Color {
        switch island.mode {
        case .music: return .purple
        case .timer: return .orange
        case .charging: return .green
        case .download: return .cyan
        case .notification: return .blue
        case .custom: return .pink
        }
    }
}

private struct EqualizerView: View {
    let color: Color
    @State private var active = false
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(color)
                    .frame(width: 2, height: active ? CGFloat(6 + i * 3) : 4)
                    .animation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true).delay(Double(i) * 0.09), value: active)
            }
        }
        .onAppear { active = true }
    }
}
