import Foundation
import CoreAnalytics
import CorePersistence

public enum CheckInEvent: AnalyticsEvent {
    case started
    case moodScoreSelected(score: Int)
    case emotionsSelected(emotions: [Emotion])
    case noteAdded(characterCount: Int)
    case completed(score: Int, emotionCount: Int, durationSeconds: TimeInterval, hasNote: Bool)
    case abandoned(atStep: CheckInStep, durationSeconds: TimeInterval)

    public var category: EventCategory { .checkin }

    public var name: String {
        switch self {
        case .started: return "checkin_started"
        case .moodScoreSelected: return "checkin_mood_selected"
        case .emotionsSelected: return "checkin_emotions_selected"
        case .noteAdded: return "checkin_note_added"
        case .completed: return "checkin_completed"
        case .abandoned: return "checkin_abandoned"
        }
    }

    public var properties: [String: AnalyticsValue] {
        switch self {
        case .started:
            return [:]
        case .moodScoreSelected(let score):
            return ["score": .int(score)]
        case .emotionsSelected(let emotions):
            return [
                "emotion_count": .int(emotions.count),
                "emotions": .string(emotions.map(\.rawValue).sorted().joined(separator: ","))
            ]
        case .noteAdded(let count):
            return ["character_count": .int(count)]
        case .completed(let score, let emotionCount, let duration, let hasNote):
            return [
                "score": .int(score),
                "emotion_count": .int(emotionCount),
                "duration_seconds": .double(duration),
                "has_note": .bool(hasNote)
            ]
        case .abandoned(let step, let duration):
            return [
                "step": .string(step.rawValue),
                "duration_seconds": .double(duration)
            ]
        }
    }
}

public enum CheckInStep: String, Sendable {
    case moodScore = "mood_score"
    case emotions = "emotions"
    case note = "note"
    case summary = "summary"
}
