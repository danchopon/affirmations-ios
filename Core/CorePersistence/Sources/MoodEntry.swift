import Foundation
import SwiftData

@Model
public final class MoodEntry {
    public var id: UUID
    public var date: Date
    /// Mood score 1-10.
    public var score: Int
    public var note: String?
    /// Stored as JSON array of Emotion raw values.
    public var emotions: [String]
    public var checkinDuration: TimeInterval
    /// One-to-optional relationship to Affirmation.
    @Relationship(deleteRule: .cascade)
    public var affirmation: Affirmation?

    public init(
        id: UUID = UUID(),
        date: Date = .now,
        score: Int,
        note: String? = nil,
        emotions: [Emotion] = [],
        checkinDuration: TimeInterval = 0
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.note = note
        self.emotions = emotions.map(\.rawValue)
        self.checkinDuration = checkinDuration
    }

    public var emotionValues: [Emotion] {
        emotions.compactMap(Emotion.init(rawValue:))
    }
}
