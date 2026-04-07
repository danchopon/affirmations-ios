import Foundation
import CoreAnalytics
import CorePersistence

public enum AffirmationEvent: AnalyticsEvent {
    case viewed(tone: ToneType, score: Int)
    case saved
    case shared
    case regenerated(tone: ToneType)

    public var category: EventCategory { .affirmation }

    public var name: String {
        switch self {
        case .viewed: return "affirmation_viewed"
        case .saved: return "affirmation_saved"
        case .shared: return "affirmation_shared"
        case .regenerated: return "affirmation_regenerated"
        }
    }

    public var properties: [String: AnalyticsValue] {
        switch self {
        case .viewed(let tone, let score):
            return ["tone": .string(tone.rawValue), "score": .int(score)]
        case .saved:
            return [:]
        case .shared:
            return [:]
        case .regenerated(let tone):
            return ["tone": .string(tone.rawValue)]
        }
    }
}
