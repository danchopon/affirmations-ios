import Foundation
import Observation
import OSLog

private let logger = Logger(subsystem: "com.affirmations", category: "Purchases")

// MARK: - Protocol

public protocol PurchaseServiceProtocol: AnyObject, Sendable {
    var isPremium: Bool { get }
}

// MARK: - Live (RevenueCat stub -- replace with actual SDK)

public final class PurchaseService: PurchaseServiceProtocol, @unchecked Sendable {
    public private(set) var isPremium: Bool = false

    private init() {}

    public static let live = PurchaseService()
}

// MARK: - Factory namespace

public extension PurchaseService {
    // Placeholder -- configure RevenueCat here:
    // Purchases.configure(withAPIKey: "your_key")
    static func configure(apiKey: String) {
        logger.info("Configuring purchases with API key (length=\(apiKey.count))")
        // TODO: Purchases.configure(withAPIKey: apiKey)
    }
}
