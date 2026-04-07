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

// MARK: - App Group store URL

public extension AppModelContainer {
    /// Returns the App Group container URL for the SwiftData store.
    /// Creates intermediate directories as needed.
    static func appGroupStoreURL() -> URL? {
        guard let base = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            logger.error("App Group container unavailable for \(appGroupIdentifier)")
            return nil
        }
        let dir = base.appendingPathComponent("Library/Application Support", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create App Group store directory: \(error)")
            return nil
        }
        return dir.appendingPathComponent("default.store")
    }

    /// Copies the default SwiftData store to the App Group container on first run.
    /// Safe to call multiple times — no-ops after the first successful migration.
    static func migrateToAppGroupIfNeeded() {
        let migrationKey = "app_group_store_migrated_v1"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        let fm = FileManager.default
        let defaultDir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let oldBase = defaultDir.appendingPathComponent("default.store")

        guard fm.fileExists(atPath: oldBase.path),
              let newBase = appGroupStoreURL() else {
            // No existing store (new install) — mark done so we skip on every launch.
            UserDefaults.standard.set(true, forKey: migrationKey)
            return
        }

        let suffixes = ["", "-shm", "-wal"]
        for suffix in suffixes {
            let src = defaultDir.appendingPathComponent("default.store\(suffix)")
            let dst = newBase.deletingLastPathComponent().appendingPathComponent("default.store\(suffix)")
            guard fm.fileExists(atPath: src.path) else { continue }
            do {
                if fm.fileExists(atPath: dst.path) { try fm.removeItem(at: dst) }
                try fm.copyItem(at: src, to: dst)
            } catch {
                logger.error("Migration copy failed for \(suffix): \(error)")
                return   // Abort — will retry next launch.
            }
        }

        UserDefaults.standard.set(true, forKey: migrationKey)
        logger.info("SwiftData store migrated to App Group container")
    }
}

// MARK: - Model container factory

public enum AppModelContainer {
    public static let shared: ModelContainer = {
        // Use App Group URL so widgets can read the same store.
        // NOTE: Combining configurations: with migrationPlan: triggers a version-tracking
        // conflict on first launch when the file does not yet exist. Schema migrations
        // are intentionally omitted here; add them via SchemaMigrationPlan when needed.
        do {
            if let url = appGroupStoreURL() {
                let config = ModelConfiguration(url: url)
                return try ModelContainer(
                    for: MoodEntry.self, Affirmation.self, UserProfile.self,
                    configurations: config
                )
            }
            // Fallback for simulator/test environments where App Group is unavailable.
            logger.warning("App Group unavailable — falling back to default store location")
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
