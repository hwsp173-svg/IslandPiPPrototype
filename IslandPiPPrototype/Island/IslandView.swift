import SwiftUI

struct IslandView: View {
    @EnvironmentObject private var controller: IslandController
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let expanded = controller.mode == .expanded
        Group {
            if expanded { expandedView } else { collapsedView }
        }
        .frame(width: (expanded ? 320 : 182) * controller.settings.scale,
               height: (expanded ? 176 : 42) * controller.settings.scale)
        .background(islandBackground)
        .clipShape(RoundedRectangle(cornerRadius: expanded ? 30 : controller.settings.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.6), radius: 12, y: 6)
        .overlay(alignment: .top) { Capsule().fill(.white.opacity(0.12)).frame(width: expanded ? 145 : 92, height: 1).padding(.top, 3) }
        .opacity(controller.settings.opacity)
        .contentShape(RoundedRectangle(cornerRadius: expanded ? 30 : controller.settings.cornerRadius, style: .continuous))
        .onTapGesture { expanded ? controller.togglePlayback() : controller.toggle() }
        .gesture(DragGesture(minimumDistance: 20).onEnded { value in if value.translation.height < -24 || value.translation.width > 90 { controller.dismiss() } })
        .accessibilityElement(children: .combine)
        .accessibilityLabel(expanded ? "Expanded island, \(controller.content.title)" : "Collapsed island, \(controller.content.title)")
        .accessibilityHint(expanded ? "Double tap to toggle action. Swipe to dismiss." : "Double tap to expand.")
        .animation(accessibilityReduceMotion ? .easeInOut(duration: 0.18) : .spring(response: 0.42 / controller.settings.animationSpeed, dampingFraction: 0.82), value: controller.mode)
    }

    private var islandBackground: some View { Color.black.overlay(Color.white.opacity(reduceTransparency ? 0 : 0.035)) }
    private var collapsedView: some View {
        HStack(spacing: 10) {
            Image(systemName: controller.content.icon).foregroundStyle(controller.content.accent).font(.system(size: 13, weight: .bold))
            if controller.content.isPlaying { EqualizerBars(color: controller.content.accent) }
            Spacer(minLength: 0)
            if let progress = controller.content.progress { Text("\(Int(progress * 100))% ").font(.caption2.monospacedDigit()).foregroundStyle(.white.opacity(0.88)) }
        }.padding(.horizontal, 14)
    }
    private var expandedView: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: controller.content.icon).font(.system(size: 25, weight: .semibold)).foregroundStyle(controller.content.accent).frame(width: 36, height: 36).background(controller.content.accent.opacity(0.16), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 3) { Text(controller.content.title).font(.headline).lineLimit(1); Text(controller.content.subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1) }
                Spacer()
            }
            if let progress = controller.content.progress { ProgressView(value: progress).tint(controller.content.accent).accessibilityLabel("Progress \(Int(progress * 100)) percent") }
            HStack(spacing: 34) {
                Button { } label: { Image(systemName: "backward.fill") }
                Button { controller.togglePlayback() } label: { Image(systemName: controller.content.isPlaying ? "pause.fill" : "play.fill").font(.title3).frame(width: 38, height: 38).background(controller.content.accent, in: Circle()) }
                Button { } label: { Image(systemName: "forward.fill") }
            }.buttonStyle(.plain).foregroundStyle(.white)
        }.padding(18)
    }
}

private struct EqualizerBars: View {
    let color: Color
    @State private var active = false
    var body: some View { HStack(spacing: 2) { ForEach(0..<3, id: \.self) { index in Capsule().fill(color).frame(width: 2, height: active ? CGFloat(7 + index * 3) : 4).animation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true).delay(Double(index) * 0.08), value: active) } }.onAppear { active = true } }
}
