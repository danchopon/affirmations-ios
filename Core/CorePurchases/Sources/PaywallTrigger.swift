import Foundation

public enum PaywallTrigger: String, Identifiable, Sendable {
    case freeAILimitReached
    case historyLimitReached
    case insightsSection
    case manualUpgrade

    public var id: String { rawValue }
}
