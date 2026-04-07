import Foundation
import SwiftData
import CorePersistence

/// Creates a read-only ModelContainer pointing at the shared App Group store.
/// Used exclusively by widget timeline providers.
func makeSharedModelContainer() -> ModelContainer? {
    guard let url = AppModelContainer.appGroupStoreURL() else { return nil }
    let config = ModelConfiguration(url: url, isStoredInMemoryOnly: false, allowsSave: false)
    return try? ModelContainer(
        for: MoodEntry.self, Affirmation.self, UserProfile.self,
        configurations: config
    )
}
