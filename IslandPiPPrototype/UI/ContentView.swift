import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var controller: IslandController
    @EnvironmentObject private var pip: PiPController
    @State private var showingCustomEditor = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("PiP source preview").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        PiPPlayerHost()
                            .frame(width: 120, height: 68)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .accessibilityLabel("Picture in Picture video source preview")
                    }
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 30).fill(LinearGradient(colors: [.gray.opacity(0.25), .black], startPoint: .top, endPoint: .bottom)).frame(height: 280)
                        if controller.settings.isEnabled {
                            IslandView().padding(.top, 46)
                        } else {
                            Text("Island disabled").font(.caption).foregroundStyle(.secondary).padding(.top, 90)
                        }
                        Text("In-app preview").font(.caption).foregroundStyle(.secondary).padding(.top, 238)
                    }
                    controls
                    settings
                    diagnostics
                }.padding()
            }.navigationTitle("Island PiP")
        }
    }
    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Demo").font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92))], spacing: 9) { ForEach(DemoKind.allCases) { kind in Button(kind.label) { if kind == .custom { showingCustomEditor = true } else { controller.show(kind) } }.buttonStyle(.bordered) } }
            HStack { Button(controller.mode == .expanded ? "Collapse" : "Expand") { controller.toggle() }.buttonStyle(.borderedProminent); Spacer(); Button(pip.isActive ? "Stop PiP" : "Start PiP") { pip.isActive ? pip.stop() : pip.start() }.buttonStyle(.bordered).disabled(!pip.isPossible) }
            if let message = pip.message { Text(message).font(.caption).foregroundStyle(.secondary) }
        }.frame(maxWidth: .infinity, alignment: .leading).sheet(isPresented: $showingCustomEditor) { CustomEditor() }
    }
    private var settings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Island").font(.headline)
            Toggle("Enable island", isOn: $controller.settings.isEnabled)
            Toggle("Haptics", isOn: $controller.settings.haptics)
            HStack { Text("Auto-collapse"); Spacer(); Text("\(controller.settings.autoCollapse, specifier: "%.0f") sec").monospacedDigit() }
            Slider(value: $controller.settings.autoCollapse, in: 0...15, step: 1)
            HStack { Text("Animation speed"); Slider(value: $controller.settings.animationSpeed, in: 0.5...1.5) }
            Text("Appearance").font(.headline).padding(.top, 4)
            HStack { Text("Size"); Slider(value: $controller.settings.scale, in: 0.8...1.15) }
            HStack { Text("Opacity"); Slider(value: $controller.settings.opacity, in: 0.65...1) }
        }.padding().background(.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
    }
    private var diagnostics: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Diagnostics").font(.headline)
            row("App version", DeviceDiagnostics.appVersion)
            row("Device model", DeviceDiagnostics.deviceModel)
            row("iOS version", DeviceDiagnostics.systemVersion)
            row("PiP available", pip.isPossible ? "Yes" : "No")
            row("Audio session", pip.audioSessionConfigured ? "Playback configured" : "Not configured")
            row("PiP state", pip.isActive ? "Active" : "Inactive")
            row("Island state", controller.mode.rawValue.capitalized)
            row("Rendering mode", pip.isActive ? "AVPlayer PiP (160×90)" : "Native SwiftUI")
            Text("Memory and battery use are intentionally not estimated: public APIs do not provide a trustworthy per-app live measurement.").font(.caption2).foregroundStyle(.secondary)
        }.padding().frame(maxWidth: .infinity, alignment: .leading).background(.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
    }
    private func row(_ name: String, _ value: String) -> some View { HStack { Text(name).foregroundStyle(.secondary); Spacer(); Text(value) } .font(.caption) }
}

private struct CustomEditor: View {
    @EnvironmentObject private var controller: IslandController
    @Environment(\.dismiss) private var dismiss
    @State private var title = "Custom title"
    @State private var subtitle = "Custom subtitle"
    @State private var icon = "sparkles"
    @State private var progress = 0.5
    @State private var duration = 5.0
    @State private var expanded = true
    var body: some View {
        NavigationStack {
            Form {
                Section("Content") { TextField("Title", text: $title); TextField("Subtitle", text: $subtitle); TextField("SF Symbol icon", text: $icon); Slider(value: $progress, in: 0...1) { Text("Progress") }; HStack { Text("Duration"); Spacer(); Text("\(duration, specifier: "%.0f") sec") }; Slider(value: $duration, in: 0...60, step: 1) }
                Section { Toggle("Start expanded", isOn: $expanded) }
            }.navigationTitle("Custom island").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Show") { controller.content = IslandContent(kind: .custom, title: title, subtitle: subtitle, icon: icon, progress: progress, duration: duration, isPlaying: true, accent: .pink); controller.setMode(expanded ? .expanded : .collapsed); dismiss() } } }
        }
    }
}
