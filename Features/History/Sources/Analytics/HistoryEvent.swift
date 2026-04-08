import Foundation
import CoreAnalytics

public enum HistoryEvent: AnalyticsEvent {
    case viewed
    case daySelected
    case entryDeleted

    public var category: EventCategory { .engagement }

    public var name: String {
        switch self {
        case .viewed: return "history_viewed"
        case .daySelected: return "history_day_selected"
        case .entryDeleted: return "history_entry_deleted"
        }
    }

    public var properties: [String: AnalyticsValue] { [:] }
}
