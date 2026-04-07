import Foundation

// MARK: - Core protocol

public protocol AnalyticsEvent: Sendable {
    var name: String { get }
    var properties: [String: AnalyticsValue] { get }
    var category: EventCategory { get }
}

// MARK: - Value type

public enum AnalyticsValue: Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
}

// MARK: - Category

public enum EventCategory: String, Sendable {
    case onboarding
    case checkin
    case affirmation
    case engagement
    case monetization
    case ai
    case system
}
