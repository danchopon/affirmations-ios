import Foundation
import OSLog

private let logger = Logger(subsystem: "com.affirmations", category: "Analytics")

// MARK: - Protocol

public protocol AnalyticsServiceProtocol: Sendable {
    func track(_ event: any AnalyticsEvent)
    func identify(userId: String, traits: [String: AnalyticsValue])
}

// MARK: - Composite service

public final class AnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    private let backends: [any AnalyticsBackend]
    private let middlewares: [any AnalyticsMiddleware]

    public init(
        backends: [any AnalyticsBackend],
        middlewares: [any AnalyticsMiddleware] = []
    ) {
        self.backends = backends
        self.middlewares = middlewares
    }

    public func track(_ event: any AnalyticsEvent) {
        var current: (any AnalyticsEvent)? = event
        for middleware in middlewares {
            guard let e = current else { return }
            current = middleware.process(e)
        }
        guard let final = current else { return }
        for backend in backends {
            backend.track(final)
        }
    }

    public func identify(userId: String, traits: [String: AnalyticsValue]) {
        for backend in backends {
            backend.identify(userId: userId, traits: traits)
        }
    }
}

// MARK: - Convenience factories

public extension AnalyticsService {
    /// Production: Amplitude + Firebase (placeholders until SDKs are added).
    static var live: AnalyticsService {
        var middlewares: [any AnalyticsMiddleware] = [
            SessionEnrichmentMiddleware()
        ]
        #if DEBUG
        middlewares.append(DebugLoggingMiddleware())
        #endif

        // Placeholder backends -- replace with AmplitudeBackend / FirebaseBackend
        // once those SDKs are added as SPM dependencies.
        let backends: [any AnalyticsBackend] = [
            ConsoleAnalyticsBackend()
        ]

        return AnalyticsService(backends: backends, middlewares: middlewares)
    }

    /// For unit tests and SwiftUI previews.
    static var noop: AnalyticsService {
        AnalyticsService(backends: [NoOpAnalyticsBackend()])
    }
}
