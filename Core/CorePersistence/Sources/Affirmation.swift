import Foundation
import SwiftData

@Model
public final class Affirmation {
    public var id: UUID
    public var text: String
    public var tone: String
    public var generatedAt: Date
    public var isFavorite: Bool
    /// Duration of AI generation in seconds, for analytics.
    public var generationDuration: TimeInterval?

    public init(
        id: UUID = UUID(),
        text: String,
        tone: ToneType,
        generatedAt: Date = .now,
        isFavorite: Bool = false,
        generationDuration: TimeInterval? = nil
    ) {
        self.id = id
        self.text = text
        self.tone = tone.rawValue
        self.generatedAt = generatedAt
        self.isFavorite = isFavorite
        self.generationDuration = generationDuration
    }

    public var toneValue: ToneType {
        ToneType(rawValue: tone) ?? .gentle
    }
}
