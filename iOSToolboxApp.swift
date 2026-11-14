import SwiftUI
import PhotosUI

// iOS Toolbox — safe SwiftUI customization shell.
// Deployment target: iOS 16.0+
// System-level changes are intentionally NOT implemented here.
// Add independently audited, version-specific adapters only after backup/testing.

@main
struct IOSToolboxApp: App {
    @StateObject private var settings = ToolboxSettings()

    var body: some Scene {
        WindowGroup {
            ToolboxRootView()
                .environmentObject(settings)
                .preferredColorScheme(.dark)
        }
    }
}

enum ToolboxCategory: String, CaseIterable, Identifiable {
    case island = "Dynamic Island"
    case display = "Display"
    case status = "Status Bar"
    case lockScreen = "Lock Screen"
    case home = "Home Screen"
    case control = "Control Center"
    case sound = "Sounds & Haptics"
    case notifications = "Notifications"
    case utilities = "Utilities"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .island: return "capsule.portrait"
        case .display: return "sun.max"
        case .status: return "battery.100"
        case .lockScreen: return "lock"
        case .home: return "square.grid.2x2"
        case .control: return "switch.2"
        case .sound: return "waveform"
        case .notifications: return "bell"
        case .utilities: return "wrench.and.screwdriver"
        }
    }
}

struct TweakFeature: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let category: ToolboxCategory
    let symbol: String
    let requiresSystemAdapter: Bool
}

@MainActor
final class ToolboxSettings: ObservableObject {
    @Published var enabled: [String: Bool] {
        didSet { save() }
    }
    @Published var selectedDevice: String {
        didSet { UserDefaults.standard.set(selectedDevice, forKey: "selectedDevice") }
    }
    @Published var islandWidth: Double {
        didSet { UserDefaults.standard.set(islandWidth, forKey: "islandWidth") }
    }
    @Published var islandHeight: Double {
        didSet { UserDefaults.standard.set(islandHeight, forKey: "islandHeight") }
    }
    @Published var islandMode: IslandMode {
        didSet { UserDefaults.standard.set(islandMode.rawValue, forKey: "islandMode") }
    }
    @Published var statusText: String {
        didSet { UserDefaults.standard.set(statusText, forKey: "statusText") }
    }
    @Published var accentName: String {
        didSet { UserDefaults.standard.set(accentName, forKey: "accentName") }
    }

    init() {
        enabled = UserDefaults.standard.dictionary(forKey: "featureStates") as? [String: Bool] ?? [:]
        selectedDevice = UserDefaults.standard.string(forKey: "selectedDevice") ?? "iPhone 16"
        islandWidth = UserDefaults.standard.object(forKey: "islandWidth") as? Double ?? 126
        islandHeight = UserDefaults.standard.object(forKey: "islandHeight") as? Double ?? 37
        islandMode = IslandMode(rawValue: UserDefaults.standard.string(forKey: "islandMode") ?? "") ?? .adaptive
        statusText = UserDefaults.standard.string(forKey: "statusText") ?? "My iPhone"
        accentName = UserDefaults.standard.string(forKey: "accentName") ?? "Blue"
    }

    func isEnabled(_ id: String) -> Bool { enabled[id] ?? false }
    func setEnabled(_ value: Bool, for id: String) { enabled[id] = value }

    func resetPreviewSettings() {
        enabled = [:]
        selectedDevice = "iPhone 16"
        islandWidth = 126
        islandHeight = 37
        islandMode = .adaptive
        statusText = "My iPhone"
        accentName = "Blue"
    }

    private func save() {
        UserDefaults.standard.set(enabled, forKey: "featureStates")
    }
}

enum IslandMode: String, CaseIterable, Identifiable {
    case adaptive = "Adaptive"
    case persistentPreview = "Persistent preview"
    case hiddenPreview = "Hidden preview"
    var id: String { rawValue }
}

enum DevicePreset: String, CaseIterable, Identifiable {
    case iphone18ProMax = "iPhone 18 Pro Max"
    case iphone18Pro = "iPhone 18 Pro"
    case iphone17ProMax = "iPhone 17 Pro Max"
    case iphone17Pro = "iPhone 17 Pro"
    case iphone16ProMax = "iPhone 16 Pro Max"
    case iphone16Pro = "iPhone 16 Pro"
    case iphone16 = "iPhone 16"
    case iphone15 = "iPhone 15"
    case iphone14 = "iPhone 14"
    case iphoneSE = "iPhone SE"

    var id: String { rawValue }

    // These are preview dimensions only, not hardware identifiers.
    var islandSize: CGSize {
        switch self {
        case .iphone18ProMax, .iphone17ProMax, .iphone16ProMax:
            return CGSize(width: 132, height: 38)
        case .iphone18Pro, .iphone17Pro, .iphone16Pro:
            return CGSize(width: 126, height: 37)
        default:
            return CGSize(width: 126, height: 37)
        }
    }

    var hasPhysicalIsland: Bool {
        switch self {
        case .iphone18ProMax, .iphone18Pro, .iphone17ProMax, .iphone17Pro,
             .iphone16ProMax, .iphone16Pro:
            return true
        default:
            return false
        }
    }
}

let toolboxFeatures: [TweakFeature] = [
    .init(id: "island.enabled", title: "Dynamic Island preview", subtitle: "Show a configurable Island preview", category: .island, symbol: "capsule.portrait", requiresSystemAdapter: false),
    .init(id: "island.persistent", title: "Persistent Island preview", subtitle: "Keep the preview visible in this app", category: .island, symbol: "pin", requiresSystemAdapter: false),
    .init(id: "island.compact", title: "Compact Island", subtitle: "Use a smaller preview layout", category: .island, symbol: "arrow.left.and.right", requiresSystemAdapter: false),
    .init(id: "display.aod.preview", title: "Always-On display guide", subtitle: "Preview an AOD-style screen inside the app", category: .display, symbol: "sun.min", requiresSystemAdapter: false),
    .init(id: "display.dim", title: "Dimmed display preview", subtitle: "Preview a dimmed appearance", category: .display, symbol: "sun.haze", requiresSystemAdapter: false),
    .init(id: "status.custom", title: "Status bar label", subtitle: "Save a label for use in supported themes", category: .status, symbol: "textformat", requiresSystemAdapter: false),
    .init(id: "status.battery", title: "Battery style concept", subtitle: "Preview alternate battery artwork", category: .status, symbol: "battery.100", requiresSystemAdapter: false),
    .init(id: "lock.wallpaper", title: "Wallpaper gallery", subtitle: "Choose an image for an in-app preview", category: .lockScreen, symbol: "photo", requiresSystemAdapter: false),
    .init(id: "lock.clock", title: "Clock style preview", subtitle: "Preview lock-screen clock treatments", category: .lockScreen, symbol: "clock", requiresSystemAdapter: false),
    .init(id: "home.icons", title: "Icon layout planner", subtitle: "Plan a home-screen icon arrangement", category: .home, symbol: "square.grid.3x3", requiresSystemAdapter: false),
    .init(id: "home.labels", title: "Icon label styling", subtitle: "Preview label styles in this app", category: .home, symbol: "textformat.abc", requiresSystemAdapter: false),
    .init(id: "control.layout", title: "Control Center planner", subtitle: "Plan a Control Center layout", category: .control, symbol: "slider.horizontal.3", requiresSystemAdapter: false),
    .init(id: "sound.haptics", title: "Haptic preferences", subtitle: "Store your preferred haptic profile", category: .sound, symbol: "waveform.path", requiresSystemAdapter: false),
    .init(id: "sound.charging", title: "Charging animation preview", subtitle: "Preview a charging animation concept", category: .sound, symbol: "bolt.fill", requiresSystemAdapter: false),
    .init(id: "notifications.style", title: "Notification style guide", subtitle: "Preview notification card styles", category: .notifications, symbol: "bell.badge", requiresSystemAdapter: false),
    .init(id: "utilities.backup", title: "Settings backup", subtitle: "Export this toolbox's preferences", category: .utilities, symbol: "externaldrive", requiresSystemAdapter: false),
    .init(id: "utilities.compatibility", title: "Compatibility report", subtitle: "Show device and OS information", category: .utilities, symbol: "checkmark.shield", requiresSystemAdapter: false),
    .init(id: "utilities.theme", title: "Accent theme", subtitle: "Choose the toolbox accent color", category: .utilities, symbol: "paintpalette", requiresSystemAdapter: false),
    .init(id: "utilities.restore", title: "Restore toolbox defaults", subtitle: "Reset preferences stored by this app", category: .utilities, symbol: "arrow.counterclockwise", requiresSystemAdapter: false),
    .init(id: "utilities.about", title: "System tweak adapter status", subtitle: "System-level actions are not connected", category: .utilities, symbol: "puzzlepiece.extension", requiresSystemAdapter: true)
]

struct ToolboxRootView: View {
    @EnvironmentObject private var settings: ToolboxSettings
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Home", systemImage: "square.grid.2x2.fill") }
                .tag(0)
            FeatureListView()
                .tabItem { Label("Tweaks", systemImage: "slider.horizontal.3") }
                .tag(1)
            IslandEditorView()
                .tabItem { Label("Island", systemImage: "capsule.portrait") }
                .tag(2)
            ToolboxSettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .tint(accentColor)
    }

    private var accentColor: Color {
        switch settings.accentName {
        case "Purple": return .purple
        case "Green": return .green
        case "Pink": return .pink
        case "Orange": return .orange
        default: return .blue
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject private var settings: ToolboxSettings

    private var activeCount: Int { settings.enabled.values.filter { $0 }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("iOS TOOLBOX")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(.secondary)
                        Text("Make iOS yours.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        Text("A customization dashboard and visual preview studio.")
                            .foregroundStyle(.secondary)
                    }

                    IslandPreviewCard()
                    HStack(spacing: 12) {
                        StatCard(title: "Modules", value: "\(toolboxFeatures.count)", symbol: "square.grid.2x2")
                        StatCard(title: "Saved toggles", value: "\(activeCount)", symbol: "checkmark.circle")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explore").font(.title2.bold())
                        ForEach(ToolboxCategory.allCases) { category in
                            NavigationLink {
                                CategoryDetailView(category: category)
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: category.symbol)
                                        .font(.title3)
                                        .frame(width: 42, height: 42)
                                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                                    Text(category.rawValue).font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                                }
                                .padding(12)
                                .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol).foregroundStyle(.cyan)
            Text(value).font(.system(size: 26, weight: .bold, design: .rounded))
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct IslandPreviewCard: View {
    @EnvironmentObject private var settings: ToolboxSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Dynamic Island studio", systemImage: "capsule.portrait")
                    .font(.headline)
                Spacer()
                Text("PREVIEW").font(.caption2.bold()).foregroundStyle(.cyan)
            }
            IslandShape(width: settings.islandWidth, height: settings.islandHeight)
                .frame(maxWidth: .infinity)
                .frame(height: 82)
            HStack {
                Text(settings.selectedDevice).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(settings.islandWidth)) × \(Int(settings.islandHeight))")
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(LinearGradient(colors: [.indigo.opacity(0.28), .blue.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 22))
    }
}

struct IslandShape: View {
    var width: Double
    var height: Double

    var body: some View {
        Capsule()
            .fill(.black)
            .overlay(Capsule().stroke(.white.opacity(0.13), lineWidth: 1))
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(0.5), radius: 12, y: 5)
            .frame(maxWidth: .infinity)
    }
}

struct FeatureListView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(ToolboxCategory.allCases) { category in
                    NavigationLink {
                        CategoryDetailView(category: category)
                    } label: {
                        Label(category.rawValue, systemImage: category.symbol)
                    }
                }
            }
            .navigationTitle("Customization")
        }
    }
}

struct CategoryDetailView: View {
    let category: ToolboxCategory
    @EnvironmentObject private var settings: ToolboxSettings

    private var features: [TweakFeature] {
        toolboxFeatures.filter { $0.category == category }
    }

    var body: some View {
        List {
            Section {
                ForEach(features) { feature in
                    FeatureRow(feature: feature)
                }
            } footer: {
                Text("Switches in this starter project save local preferences and control previews. They do not change iOS system files.")
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let feature: TweakFeature
    @EnvironmentObject private var settings: ToolboxSettings

    var body: some View {
        Toggle(isOn: Binding(
            get: { settings.isEnabled(feature.id) },
            set: { settings.setEnabled($0, for: feature.id) }
        )) {
            HStack(spacing: 12) {
                Image(systemName: feature.symbol)
                    .frame(width: 30)
                    .foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 3) {
                    Text(feature.title).font(.body.weight(.medium))
                    Text(feature.subtitle).font(.caption).foregroundStyle(.secondary)
                    if feature.requiresSystemAdapter {
                        Text("Adapter not connected")
                            .font(.caption2.bold())
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .tint(.cyan)
    }
}

struct IslandEditorView: View {
    @EnvironmentObject private var settings: ToolboxSettings

    var body: some View {
        NavigationStack {
            Form {
                Section("Device preview preset") {
                    Picker("Model", selection: $settings.selectedDevice) {
                        ForEach(DevicePreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset.rawValue)
                        }
                    }
                    if let preset = DevicePreset(rawValue: settings.selectedDevice) {
                        Label(
                            preset.hasPhysicalIsland ? "Preset includes a physical Island" : "This preset has no physical Dynamic Island",
                            systemImage: preset.hasPhysicalIsland ? "checkmark.circle.fill" : "info.circle"
                        )
                        .font(.caption)
                        .foregroundStyle(preset.hasPhysicalIsland ? .green : .orange)
                    }
                }

                Section("Preview dimensions") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Width")
                            Spacer()
                            Text("\(Int(settings.islandWidth)) pt").monospacedDigit()
                        }
                        Slider(value: $settings.islandWidth, in: 80...180, step: 1)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Height")
                            Spacer()
                            Text("\(Int(settings.islandHeight)) pt").monospacedDigit()
                        }
                        Slider(value: $settings.islandHeight, in: 24...65, step: 1)
                    }
                    IslandShape(width: settings.islandWidth, height: settings.islandHeight)
                        .frame(height: 90)
                }

                Section("Display mode") {
                    Picker("Mode", selection: $settings.islandMode) {
                        ForEach(IslandMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    Text("These modes affect the in-app preview only, not the system Dynamic Island.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Section {
                    Button("Use selected device's preview dimensions") {
                        guard let preset = DevicePreset(rawValue: settings.selectedDevice) else { return }
                        settings.islandWidth = preset.islandSize.width
                        settings.islandHeight = preset.islandSize.height
                    }
                    Button("Reset Island preview", role: .destructive) {
                        settings.islandWidth = 126
                        settings.islandHeight = 37
                        settings.islandMode = .adaptive
                    }
                }
            }
            .navigationTitle("Island Studio")
        }
    }
}

struct ToolboxSettingsView: View {
    @EnvironmentObject private var settings: ToolboxSettings
    @State private var showingReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Accent color", selection: $settings.accentName) {
                        ForEach(["Blue", "Purple", "Green", "Pink", "Orange"], id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section("Device information") {
                    LabeledContent("Target OS", value: "iOS 27.0.1")
                    LabeledContent("Device preset", value: settings.selectedDevice)
                    LabeledContent("Runtime OS", value: ProcessInfo.processInfo.operatingSystemVersionString)
                }

                Section("Custom status label") {
                    TextField("Label", text: $settings.statusText)
                    Text("Stored locally for theme previews; does not alter the real status bar.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Section("System integration") {
                    Label("No exploit code included", systemImage: "lock.shield")
                    Text("This starter app does not escape the app sandbox or write protected system configuration. Add only audited adapters with explicit user confirmation, backups and verified version checks.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Section("Data") {
                    ShareLink(item: settingsBackup) {
                        Label("Export settings backup", systemImage: "square.and.arrow.up")
                    }
                    Button("Reset all toolbox settings", role: .destructive) {
                        showingReset = true
                    }
                }

                Section("About") {
                    Text("iOS Toolbox")
                    Text("SwiftUI customization dashboard • iOS 16+ deployment target")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Reset toolbox settings?", isPresented: $showingReset, titleVisibility: .visible) {
                Button("Reset settings", role: .destructive) { settings.resetPreviewSettings() }
            } message: {
                Text("This resets preferences stored by iOS Toolbox. It does not restore or modify iOS system settings.")
            }
        }
    }

    private var settingsBackup: String {
        let payload: [String: Any] = [
            "app": "iOS Toolbox",
            "schemaVersion": 1,
            "targetOS": "iOS 27.0.1",
            "enabledFeatures": settings.enabled,
            "selectedDevice": settings.selectedDevice,
            "islandWidth": settings.islandWidth,
            "islandHeight": settings.islandHeight,
            "islandMode": settings.islandMode.rawValue,
            "statusText": settings.statusText,
            "accentName": settings.accentName
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]) else {
            return "{}"
        }
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
