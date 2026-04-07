import Foundation

public enum ToneType: String, Codable, CaseIterable, Sendable {
    case motivational
    case gentle
    case spiritual

    public var displayName: String {
        switch self {
        case .motivational: return "Motivational"
        case .gentle: return "Gentle"
        case .spiritual: return "Spiritual"
        }
    }

    public var description: String {
        switch self {
        case .motivational: return "Energizing and action-oriented"
        case .gentle: return "Soft, nurturing, and kind"
        case .spiritual: return "Grounded, mindful, and introspective"
        }
    }
}
