import SwiftUI
import OSLog
import CorePersistence

private let logger = Logger(subsystem: "com.affirmations", category: "ErrorHandler")

/// Centralised error presenter. Injected via SwiftUI environment.
///
/// - Blocking errors (persistence, unknown) → alert, requires dismissal.
/// - Transient errors (network, AI) → toast message, auto-dismissed.
///
/// All errors are logged via os.Logger regardless of presentation.
@Observable
final class ErrorHandler {
    /// Set by the view layer to show an alert.
    var activeAlert: AppError?
    /// Set by the view layer to show a toast / inline banner.
    var toastMessage: String?

    func handle(_ error: AppError) {
        logger.error("AppError [\(String(describing: error.severity))]: \(error.userMessage)")
        switch error.severity {
        case .blocking:
            activeAlert = error
        case .transient:
            toastMessage = error.userMessage
        }
    }
}

// MARK: - Environment

private struct ErrorHandlerKey: EnvironmentKey {
    static let defaultValue = ErrorHandler()
}

extension EnvironmentValues {
    var errorHandler: ErrorHandler {
        get { self[ErrorHandlerKey.self] }
        set { self[ErrorHandlerKey.self] = newValue }
    }
}
