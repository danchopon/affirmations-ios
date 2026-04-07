import SwiftUI

// MARK: - Environment key

struct AnalyticsServiceKey: EnvironmentKey {
    static let defaultValue: any AnalyticsServiceProtocol = AnalyticsService.noop
}

public extension EnvironmentValues {
    var analytics: any AnalyticsServiceProtocol {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
}
