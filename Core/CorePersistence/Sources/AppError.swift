import Foundation

/// Typed error categories used across the app.
/// Feature view models throw AppError so the centralized ErrorHandler
/// can decide presentation (toast, alert, or silent log) by category.
public enum AppError: Error {
    case persistence(underlying: Error)
    case network(underlying: Error)
    case ai(AIFailure)
    case unknown(underlying: Error)

    public enum AIFailure {
        case rateLimitExceeded
        case consentRequired
        case serviceUnavailable
    }

    /// Human-readable description for user-facing alerts and toasts.
    public var userMessage: String {
        switch self {
        case .persistence:
            return "Could not save your data. Please try again."
        case .network:
            return "No connection. Check your internet and try again."
        case .ai(let failure):
            switch failure {
            case .rateLimitExceeded:
                return "Daily AI limit reached. Showing an offline affirmation."
            case .consentRequired:
                return "Enable AI affirmations in Settings."
            case .serviceUnavailable:
                return "AI is temporarily unavailable. Showing an offline affirmation."
            }
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }

    /// Severity drives how ErrorHandler presents the error.
    public var severity: Severity {
        switch self {
        case .persistence: return .blocking
        case .network: return .transient
        case .ai: return .transient
        case .unknown: return .blocking
        }
    }

    public enum Severity {
        /// Show an alert. Requires explicit user dismissal.
        case blocking
        /// Show a toast / inline message. Dismisses automatically.
        case transient
    }
}
