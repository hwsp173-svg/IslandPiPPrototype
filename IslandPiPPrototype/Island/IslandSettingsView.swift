import SwiftUI

struct IslandSettingsView: View {
    @EnvironmentObject private var island: IslandState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Dynamic Island Demo States") {
                    ForEach(IslandMode.allCases) { mode in
                        Button {
                            island.mode = mode
                            island.expanded = false
                            Haptics.light()
                            dismiss()
                        } label: {
                            HStack {
                                Label(mode.title, systemImage: iconFor(mode))
                                    .foregroundStyle(colorFor(mode))
                                Spacer()
                                if island.mode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Island Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func iconFor(_ mode: IslandMode) -> String {
        switch mode {
        case .music: return "music.note"
        case .timer: return "timer"
        case .charging: return "bolt.fill"
        case .download: return "arrow.down.circle.fill"
        case .notification: return "bell.fill"
        case .custom: return "sparkles"
        }
    }

    private func colorFor(_ mode: IslandMode) -> Color {
        switch mode {
        case .music: return .purple
        case .timer: return .orange
        case .charging: return .green
        case .download: return .cyan
        case .notification: return .blue
        case .custom: return .pink
        }
    }
}
