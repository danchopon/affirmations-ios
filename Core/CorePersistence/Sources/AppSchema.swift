import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.affirmations", category: "Persistence")

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

// MARK: - App Group

/// Shared container identifier. Used by the main app and the widget extension.
/// Must match the entitlement in App/Affirmations.entitlements and any future widget target.
public let appGroupIdentifier = "group.com.affirmations.shared"

// MARK: - Model container factory

public enum AppModelContainer {
    public static let shared: ModelContainer = {
        do {
            // Use variadics form — no explicit Schema() or ModelConfiguration(url:) here.
            // Combining configurations: with migrationPlan: triggers a version-tracking
            // conflict in SwiftData on first launch (database does not yet exist).
            // The App Group store migration is deferred to when a widget target is added;
            // at that point a SchemaMigrationPlan stage can move the file atomically.
            return try ModelContainer(
                for: MoodEntry.self, Affirmation.self, UserProfile.self,
                migrationPlan: AppMigrationPlan.self
            )
        } catch {
            logger.critical("Failed to create ModelContainer: \(error)")
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
