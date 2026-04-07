import SwiftUI
import CheckIn
import History
import Insights
import Settings
import Paywall

struct ContentView: View {
    @Environment(AppRouter.self) private var router
    @State private var errorHandler = ErrorHandler()

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
        .alert(
            "Error",
            isPresented: Binding(
                get: { errorHandler.activeAlert != nil },
                set: { if !$0 { errorHandler.activeAlert = nil } }
            ),
            presenting: errorHandler.activeAlert
        ) { _ in
            Button("OK") { errorHandler.activeAlert = nil }
        } message: { error in
            Text(error.userMessage)
        }
        .environment(\.errorHandler, errorHandler)
    }
}
