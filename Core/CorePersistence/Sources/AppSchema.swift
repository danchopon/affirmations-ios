import Foundation
import SwiftData

// MARK: - Versioned schema for safe migrations

public enum AppSchemaV1: VersionedSchema {
    public static var versionIdentifier = Schema.Version(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [MoodEntry.self, Affirmation.self, UserProfile.self]
    }
}

public enum AppMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [AppSchemaV1.self]
    }

    public static var stages: [MigrationStage] {
        []
    }
}

// MARK: - Model container factory

public enum AppModelContainer {
    public static let shared: ModelContainer = {
        do {
            // Use variadics form -- no explicit Schema() creation to avoid
            // version tracking conflict with migration plan on first launch.
            return try ModelContainer(
                for: MoodEntry.self, Affirmation.self, UserProfile.self,
                migrationPlan: AppMigrationPlan.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    /// In-memory container for tests and previews.
    public static var preview: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try ModelContainer(
                for: MoodEntry.self, Affirmation.self, UserProfile.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }()
}
