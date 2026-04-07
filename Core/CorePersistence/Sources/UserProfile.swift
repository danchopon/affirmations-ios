import Foundation
import SwiftData

@Model
public final class UserProfile {
    public var id: UUID
    public var preferredTone: String
    public var reminderTime: Date?
    public var language: String
    /// Whether the user has consented to AI processing of mood data.
    public var aiConsentGranted: Bool
    public var aiConsentDate: Date?

    public init(
        id: UUID = UUID(),
        preferredTone: ToneType = .gentle,
        reminderTime: Date? = nil,
        language: String = Locale.current.language.languageCode?.identifier ?? "en",
        aiConsentGranted: Bool = false
    ) {
        self.id = id
        self.preferredTone = preferredTone.rawValue
        self.reminderTime = reminderTime
        self.language = language
        self.aiConsentGranted = aiConsentGranted
    }

    public var preferredToneValue: ToneType {
        ToneType(rawValue: preferredTone) ?? .gentle
    }
}
