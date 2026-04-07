import Foundation
import OSLog

private let logger = Logger(subsystem: "com.affirmations", category: "Analytics")

// MARK: - Debug logger middleware

/// Logs every event via os.Logger in DEBUG builds.
public struct DebugLoggingMiddleware: AnalyticsMiddleware {
    public init() {}

    public func process(_ event: any AnalyticsEvent) -> (any AnalyticsEvent)? {
        #if DEBUG
        logger.debug("event=\(event.name, privacy: .public) category=\(event.category.rawValue, privacy: .public)")
        #endif
        return event
    }
}

// MARK: - Session enrichment middleware

/// Attaches a stable session ID to every event so Amplitude can group events per session.
public final class SessionEnrichmentMiddleware: AnalyticsMiddleware, @unchecked Sendable {
    private let sessionId: String = UUID().uuidString

    public init() {}

    public func process(_ event: any AnalyticsEvent) -> (any AnalyticsEvent)? {
        EnrichedEvent(wrapped: event, extra: ["session_id": .string(sessionId)])
    }
}

// MARK: - Schema validation middleware (DEBUG only)

/// Asserts that a tracked event's property keys match the registered schema.
/// Catches typos and missing/extra properties during development.
public struct SchemaValidationMiddleware: AnalyticsMiddleware {
    private let schemas: [String: Set<String>]

    public init(schemas: [String: Set<String>]) {
        self.schemas = schemas
    }

    public func process(_ event: any AnalyticsEvent) -> (any AnalyticsEvent)? {
        #if DEBUG
        if let expected = schemas[event.name] {
            let actual = Set(event.properties.keys)
            if actual != expected {
                let missing = expected.subtracting(actual)
                let extra = actual.subtracting(expected)
                var msg = "[AnalyticsSchema] '\(event.name)' mismatch."
                if !missing.isEmpty { msg += " Missing: \(missing.sorted())." }
                if !extra.isEmpty { msg += " Extra: \(extra.sorted())." }
                assertionFailure(msg)
            }
        }
        #endif
        return event
    }
}

// MARK: - EnrichedEvent (internal wrapper)

struct EnrichedEvent: AnalyticsEvent {
    private let wrapped: any AnalyticsEvent
    private let extra: [String: AnalyticsValue]

    init(wrapped: any AnalyticsEvent, extra: [String: AnalyticsValue]) {
        self.wrapped = wrapped
        self.extra = extra
    }

    var name: String { wrapped.name }
    var category: EventCategory { wrapped.category }
    var properties: [String: AnalyticsValue] { wrapped.properties.merging(extra) { _, new in new } }
}
