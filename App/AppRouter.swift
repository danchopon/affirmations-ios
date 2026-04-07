import Foundation
import Observation
import CorePurchases

@Observable
final class AppRouter {
    var showPaywall: PaywallTrigger?
    var showOnboarding: Bool = false

    func presentPaywall(trigger: PaywallTrigger) {
        showPaywall = trigger
    }

    func dismissPaywall() {
        showPaywall = nil
    }
}
