import Foundation

// MARK: - Backend protocol

public protocol AnalyticsBackend: Sendable {
    func track(_ event: any AnalyticsEvent)
    func identify(userId: String, traits: [String: AnalyticsValue])
}

// MARK: - Middleware protocol

public protocol AnalyticsMiddleware: Sendable {
    /// Return nil to drop the event, return modified event to continue the chain.
    func process(_ event: any AnalyticsEvent) -> (any AnalyticsEvent)?
}

// MARK: - NoOp (previews / tests)

public struct NoOpAnalyticsBackend: AnalyticsBackend {
    public init() {}
    public func track(_ event: any AnalyticsEvent) {}
    public func identify(userId: String, traits: [String: AnalyticsValue]) {}
}

// MARK: - Console (debug)

public struct ConsoleAnalyticsBackend: AnalyticsBackend {
    public init() {}

    public func track(_ event: any AnalyticsEvent) {
        var parts = ["[Analytics] \(event.category.rawValue)/\(event.name)"]
        for (key, value) in event.properties.sorted(by: { $0.key < $1.key }) {
            parts.append("  \(key): \(value.debugDescription)")
        }
        print(parts.joined(separator: "\n"))
    }

    public func identify(userId: String, traits: [String: AnalyticsValue]) {
        print("[Analytics] identify: \(userId) traits: \(traits.keys.sorted())")
    }
}

extension AnalyticsValue: CustomStringConvertible {
    public var description: String { debugDescription }
    public var debugDescription: String {
        switch self {
        case .string(let v): return "\"\(v)\""
        case .int(let v): return "\(v)"
        case .double(let v): return "\(v)"
        case .bool(let v): return "\(v)"
        }
    }
}
