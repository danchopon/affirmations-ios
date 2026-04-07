import Foundation
import SwiftUI
import Observation
import CorePurchases

/// Central router for the app.
///
/// - Holds one NavigationPath per tab for typed, programmatic push navigation.
/// - Handles modal sheets (paywall, onboarding) so any feature can trigger them.
@Observable
final class AppRouter {
    // MARK: - Tab navigation paths

    var checkInPath = NavigationPath()
    var historyPath = NavigationPath()
    var insightsPath = NavigationPath()
    var settingsPath = NavigationPath()

    // MARK: - Modals

    var showPaywall: PaywallTrigger?
    var showOnboarding: Bool = false

    // MARK: - Modal actions

    func presentPaywall(trigger: PaywallTrigger) {
        showPaywall = trigger
    }

    func dismissPaywall() {
        showPaywall = nil
    }

    // MARK: - Tab reset

    /// Pop a tab back to its root. Useful for double-tap-on-tab-bar behaviour.
    func resetTab(_ tab: AppTab) {
        switch tab {
        case .checkIn:   checkInPath   = NavigationPath()
        case .history:   historyPath   = NavigationPath()
        case .insights:  insightsPath  = NavigationPath()
        case .settings:  settingsPath  = NavigationPath()
        }
    }
}

enum AppTab {
    case checkIn, history, insights, settings
}
