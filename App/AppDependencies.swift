import Foundation
import CoreAnalytics
import CoreAI
import CorePersistence
import CorePurchases

/// Root DI container. Held as @State in the App scene.
/// Injected into SwiftUI environment so features can read individual services.
@Observable
public final class AppDependencies {
    public let analytics: any AnalyticsServiceProtocol
    public let ai: any AIServiceProtocol
    public let purchases: any PurchaseServiceProtocol

    public init(
        analytics: any AnalyticsServiceProtocol = AnalyticsService.live,
        ai: any AIServiceProtocol = AIService.live,
        purchases: any PurchaseServiceProtocol = PurchaseService.live
    ) {
        self.analytics = analytics
        self.ai = ai
        self.purchases = purchases
    }
}
