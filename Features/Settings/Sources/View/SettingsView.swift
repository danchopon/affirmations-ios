import SwiftUI
import SwiftData
import CorePersistence
import CorePurchases
import CoreAnalytics
import DesignSystem

public struct SettingsView: View {
    @Environment(\.analytics) private var analytics
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Query(sort: \UserProfile.id) private var profiles: [UserProfile]

    @State private var viewModel: SettingsViewModel?

    public init() {}

    private var profile: UserProfile? { profiles.first }

    public var body: some View {
        Group {
            if let vm = viewModel {
                SettingsForm(vm: vm, profile: profile, router: router)
            } else {
                ProgressView()
                    .onAppear { setup() }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    private func setup() {
        guard viewModel == nil else { return }
        viewModel = SettingsViewModel(
            profile: profile,
            modelContext: modelContext,
            analytics: analytics
        )
    }
}

// MARK: - Form

@MainActor
private struct SettingsForm: View {
    @Bindable var vm: SettingsViewModel
    let profile: UserProfile?
    let router: AppRouter

    var body: some View {
        Form {
            // Tone
            Section {
                Picker("Affirmation tone", selection: $vm.selectedTone) {
                    ForEach(ToneType.allCases, id: \.self) { tone in
                        VStack(alignment: .leading) {
                            Text(tone.displayName)
                            Text(tone.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(tone)
                    }
                }
                .pickerStyle(.inline)
                .onChange(of: vm.selectedTone) { _, tone in
                    vm.saveTone(tone, profile: profile)
                }
            } header: {
                Text("Tone")
            }

            // Reminders
            Section {
                Toggle("Daily reminder", isOn: Binding(
                    get: { vm.reminderEnabled },
                    set: { enabled in
                        Task { await vm.toggleReminder(enabled: enabled, profile: profile) }
                    }
                ))
                .disabled(vm.isRequestingPermission)

                if vm.reminderEnabled {
                    DatePicker(
                        "Time",
                        selection: Binding(
                            get: { vm.reminderTime },
                            set: { time in
                                Task { await vm.updateReminderTime(time, profile: profile) }
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            } header: {
                Text("Reminders")
            }

            // AI consent
            Section {
                Toggle("Allow AI affirmations", isOn: Binding(
                    get: { profile?.aiConsentGranted ?? false },
                    set: { granted in vm.toggleAIConsent(granted: granted, profile: profile) }
                ))
            } header: {
                Text("Privacy")
            } footer: {
                Text("Your mood data is sent to an AI service to personalise affirmations. You can revoke consent at any time.")
            }

            // Subscription
            Section {
                Button("Manage Subscription") {
                    router.presentPaywall(trigger: .manualUpgrade)
                }
            }

            // App version
            Section {
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(version) (\(build))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
