import SwiftUI

struct ContentView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        TabView {
            Text("Check In")
                .tabItem { Label("Today", systemImage: "heart.fill") }

            Text("History")
                .tabItem { Label("History", systemImage: "calendar") }

            Text("Insights")
                .tabItem { Label("Insights", systemImage: "chart.bar.fill") }

            Text("Settings")
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .sheet(item: Binding(
            get: { router.showPaywall },
            set: { _ in router.dismissPaywall() }
        )) { _ in
            Text("Paywall")
        }
    }
}
