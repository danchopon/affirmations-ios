import Foundation
import CoreAnalytics
import CorePurchases

public enum PaywallEvent: AnalyticsEvent {
    case shown(trigger: PaywallTrigger)
    case dismissed(trigger: PaywallTrigger)
    case subscriptionStarted(plan: String, trigger: PaywallTrigger)

    public var category: EventCategory { .monetization }

    public var name: String {
        switch self {
        case .shown: return "paywall_shown"
        case .dismissed: return "paywall_dismissed"
        case .subscriptionStarted: return "subscription_started"
        }
    }

    public var properties: [String: AnalyticsValue] {
        switch self {
        case .shown(let trigger):
            return ["trigger": .string(trigger.rawValue)]
        case .dismissed(let trigger):
            return ["trigger": .string(trigger.rawValue)]
        case .subscriptionStarted(let plan, let trigger):
            return ["plan": .string(plan), "trigger": .string(trigger.rawValue)]
        }
    }
}
