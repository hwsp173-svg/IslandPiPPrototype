import SwiftUI

/// Settings panel for the Island demo modes, accessible from the toolbar.
struct IslandSettingsView: View {
    @EnvironmentObject private var islandState: IslandState
    @EnvironmentObject private var browserState: BrowserState
    @Environment(\.dismiss) private var dismiss
    @State private var customTitle = "Custom Title"
    @State private var customSubtitle = "Custom subtitle"
    @State private var customIcon = "sparkles"
    @State private var customProgress = 0.5
    @State private var startExpanded = true

    var body: some View {
        NavigationStack {
            List {
                // Demo modes
                Section("Island Demo Modes") {
                    ForEach(IslandContentKind.allCases) { kind in
                        if kind != .custom {
                            Button {
                                islandState.showDemo(kind, expanded: true)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: iconForKind(kind))
                                        .foregroundStyle(colorForKind(kind))
                                        .frame(width: 24)
                                    Text(kind.label)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    if islandState.content.kind == kind {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                }
                            }
                        }
                    }
                }

                // Custom content
                Section("Custom Island Content") {
                    TextField("Title", text: $customTitle)
                    TextField("Subtitle", text: $customSubtitle)
                    TextField("SF Symbol icon", text: $customIcon)
                    HStack {
                        Text("Progress")
                        Spacer()
                        Text("\(Int(customProgress * 100))%")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $customProgress, in: 0...1)
                    Toggle("Start expanded", isOn: $startExpanded)
                    Button("Show Custom Island") {
                        islandState.updateCustomContent(
                            title: customTitle,
                            subtitle: customSubtitle,
                            icon: customIcon,
                            progress: customProgress,
                            expanded: startExpanded
                        )
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }

                // Settings
                Section("Settings") {
                    Toggle("Haptic Feedback", isOn: $islandState.haptics)

                    Picker("Search Engine", selection: $browserState.searchEngine) {
                        ForEach(BrowserState.SearchEngine.allCases) { engine in
                            Text(engine.displayName).tag(engine)
                        }
                    }
                }

                // Quick actions
                Section("Island") {
                    Button("Expand") { islandState.expand(); dismiss() }
                    Button("Collapse") { islandState.collapse(); dismiss() }
                }
            }
            .navigationTitle("Island Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func iconForKind(_ kind: IslandContentKind) -> String {
        switch kind {
        case .music: return "music.note"
        case .timer: return "timer"
        case .charging: return "bolt.fill"
        case .download: return "arrow.down.circle.fill"
        case .notification: return "bell.badge.fill"
        case .custom: return "sparkles"
        }
    }

    private func colorForKind(_ kind: IslandContentKind) -> Color {
        switch kind {
        case .music: return .purple
        case .timer: return .orange
        case .charging: return .green
        case .download: return .cyan
        case .notification: return .blue
        case .custom: return .pink
        }
    }
}
