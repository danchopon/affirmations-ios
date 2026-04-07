import Foundation
import Observation

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
        // TODO: Purchases.configure(withAPIKey: apiKey)
    }
}
