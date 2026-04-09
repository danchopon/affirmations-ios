import Foundation
import CoreAnalytics
import CorePersistence

public enum SettingsEvent: AnalyticsEvent {
    case toneChanged(tone: ToneType)
    case reminderToggled(enabled: Bool)
    case aiConsentToggled(granted: Bool)
    case manageSubscriptionTapped

    public var category: EventCategory { .engagement }

    public var name: String {
        switch self {
        case .toneChanged: return "settings_tone_changed"
        case .reminderToggled: return "settings_reminder_toggled"
        case .aiConsentToggled: return "settings_ai_consent_toggled"
        case .manageSubscriptionTapped: return "settings_manage_subscription_tapped"
        }
    }

    public var properties: [String: AnalyticsValue] {
        switch self {
        case .toneChanged(let tone):
            return ["tone": .string(tone.rawValue)]
        case .reminderToggled(let enabled):
            return ["enabled": .bool(enabled)]
        case .aiConsentToggled(let granted):
            return ["granted": .bool(granted)]
        case .manageSubscriptionTapped:
            return [:]
        }
    }
}
