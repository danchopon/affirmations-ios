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
            CheckInView()
                .tabItem { Label("Today", systemImage: "heart.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "calendar") }

            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar.fill") }

            SettingsView()
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
