import Foundation
import CoreAnalytics

public enum InsightsEvent: AnalyticsEvent {
    case viewed

    public var category: EventCategory { .engagement }
    public var name: String { "insights_viewed" }
    public var properties: [String: AnalyticsValue] { [:] }
}
