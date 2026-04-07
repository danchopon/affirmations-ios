import SwiftUI
import CorePersistence

// MARK: - Environment key

struct AIServiceKey: EnvironmentKey {
    static let defaultValue: any AIServiceProtocol = LocalAffirmationService()
}

public extension EnvironmentValues {
    var aiService: any AIServiceProtocol {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }
}
