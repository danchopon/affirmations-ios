import Foundation
import Observation
import CoreAnalytics
import CorePurchases

@Observable
@MainActor
public final class PaywallViewModel {
    private let analytics: any AnalyticsServiceProtocol
    private let trigger: PaywallTrigger

    public init(analytics: any AnalyticsServiceProtocol, trigger: PaywallTrigger) {
        self.analytics = analytics
        self.trigger = trigger
        analytics.track(PaywallEvent.shown(trigger: trigger))
    }
}
