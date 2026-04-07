import SwiftUI
import SwiftData
import CoreAnalytics
import CoreAI
import CorePersistence

@main
struct AffirmationsApp: App {
    @State private var dependencies = AppDependencies()
    @State private var router = AppRouter()

    init() {
        // Migrate default store to App Group before the container is first accessed.
        AppModelContainer.migrateToAppGroupIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
                .environment(\.analytics, dependencies.analytics)
                .environment(\.aiService, dependencies.ai)
        }
        .modelContainer(AppModelContainer.shared)
    }
}
