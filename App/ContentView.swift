import SwiftUI
import CheckIn
import History
import Insights
import Settings
import Paywall

struct ContentView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        TabView {
            NavigationStack(path: $router.checkInPath) {
                CheckInView()
            }
            .tabItem { Label("Today", systemImage: "heart.fill") }

            NavigationStack(path: $router.historyPath) {
                HistoryView()
            }
            .tabItem { Label("History", systemImage: "calendar") }

            NavigationStack(path: $router.insightsPath) {
                InsightsView()
            }
            .tabItem { Label("Insights", systemImage: "chart.bar.fill") }

            NavigationStack(path: $router.settingsPath) {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gear") }
        }
        .sheet(item: $router.showPaywall) { _ in
            PaywallView()
        }
        .sheet(isPresented: $router.showOnboarding) {
            // OnboardingView() — add when onboarding is built
            Text("Welcome")
        }
    }
}
