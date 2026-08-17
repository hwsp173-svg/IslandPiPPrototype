import SwiftUI

struct IslandSettingsView: View {
    @EnvironmentObject private var island: IslandState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Demo mode", selection: $island.mode) {
                        ForEach(IslandMode.allCases) { mode in
                            Label(mode.title, systemImage: mode.symbol)
                                .tag(mode)
                        }
                    }
                    .onChange(of: island.mode) { _, mode in
                        island.setMode(mode)
                    }
                } header: {
                    Text("Dynamic Island")
                } footer: {
                    Text("Choose a live demo to preview in the in-app island. All modes stay inside IslandBrowser.")
                }

                Section("Custom mode") {
                    TextField("Title", text: $island.customTitle)
                    TextField("Message", text: $island.customSubtitle)
                    TextField("SF Symbol name", text: $island.customSymbol)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section {
                    Button {
                        island.showNotification()
                        dismiss()
                    } label: {
                        Label("Preview notification", systemImage: "bell.badge.fill")
                    }
                } footer: {
                    Text("Notifications expand briefly, provide haptic feedback, and collapse automatically.")
                }
            }
            .navigationTitle("Island settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
