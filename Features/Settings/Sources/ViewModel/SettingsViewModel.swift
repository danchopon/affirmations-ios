import Foundation
import Observation
import OSLog
import SwiftData
import CoreAnalytics
import CorePersistence
import CoreNotifications

private let logger = Logger(subsystem: "com.affirmations", category: "Settings")

@Observable
@MainActor
public final class SettingsViewModel {
    // MARK: - UI state (shadow copies of profile values)

    var selectedTone: ToneType
    var reminderEnabled: Bool
    var reminderTime: Date
    var isRequestingPermission: Bool = false

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let analytics: any AnalyticsServiceProtocol
    private let notificationService: NotificationService

    public init(
        profile: UserProfile?,
        modelContext: ModelContext,
        analytics: any AnalyticsServiceProtocol
    ) {
        self.modelContext = modelContext
        self.analytics = analytics
        self.notificationService = .shared
        self.selectedTone = profile?.preferredToneValue ?? .gentle
        self.reminderEnabled = profile?.reminderTime != nil
        self.reminderTime = profile?.reminderTime
            ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now)
            ?? .now
    }

    // MARK: - Actions

    func saveTone(_ tone: ToneType, profile: UserProfile?) {
        selectedTone = tone
        guard let profile else { return }
        profile.preferredTone = tone.rawValue
        save()
        analytics.track(SettingsEvent.toneChanged(tone: tone))
    }

    func toggleReminder(enabled: Bool, profile: UserProfile?) async {
        guard let profile else { return }
        if enabled {
            isRequestingPermission = true
            let granted = await notificationService.requestPermission()
            isRequestingPermission = false
            guard granted else { return }
            profile.reminderTime = reminderTime
            save()
            await notificationService.scheduleDailyReminder(at: reminderTime)
            reminderEnabled = true
        } else {
            profile.reminderTime = nil
            save()
            notificationService.cancelDailyReminder()
            reminderEnabled = false
        }
        analytics.track(SettingsEvent.reminderToggled(enabled: reminderEnabled))
    }

    func updateReminderTime(_ time: Date, profile: UserProfile?) async {
        reminderTime = time
        guard let profile, reminderEnabled else { return }
        profile.reminderTime = time
        save()
        await notificationService.scheduleDailyReminder(at: time)
    }

    func toggleAIConsent(granted: Bool, profile: UserProfile?) {
        guard let profile else { return }
        profile.aiConsentGranted = granted
        if !granted { profile.aiConsentDate = nil }
        save()
        analytics.track(SettingsEvent.aiConsentToggled(granted: granted))
    }

    // MARK: - Private

    private func save() {
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save settings: \(error)")
        }
    }
}
