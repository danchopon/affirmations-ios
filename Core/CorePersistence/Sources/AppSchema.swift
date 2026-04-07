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
        let schema = Schema(AppSchemaV1.models, version: AppSchemaV1.versionIdentifier)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, migrationPlan: AppMigrationPlan.self, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    /// In-memory container for tests and previews.
    public static var preview: ModelContainer = {
        let schema = Schema(AppSchemaV1.models, version: AppSchemaV1.versionIdentifier)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }()
}
