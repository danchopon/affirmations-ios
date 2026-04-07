import Foundation
import CorePersistence

/// Simple in-memory cache for affirmation responses.
/// Keyed on (score, sorted emotions, tone) with TTL.
final class AIResponseCache: @unchecked Sendable {
    private struct Entry {
        let text: String
        let expiresAt: Date
    }

    private var store: [String: Entry] = [:]
    private let ttl: TimeInterval

    init(ttl: TimeInterval = 4 * 60 * 60) { // 4 hours
        self.ttl = ttl
    }

    func get(score: Int, emotions: [Emotion], tone: ToneType) -> String? {
        let key = cacheKey(score: score, emotions: emotions, tone: tone)
        guard let entry = store[key], entry.expiresAt > .now else {
            store.removeValue(forKey: key)
            return nil
        }
        return entry.text
    }

    func set(text: String, score: Int, emotions: [Emotion], tone: ToneType) {
        let key = cacheKey(score: score, emotions: emotions, tone: tone)
        store[key] = Entry(text: text, expiresAt: .now.addingTimeInterval(ttl))
    }

    private func cacheKey(score: Int, emotions: [Emotion], tone: ToneType) -> String {
        let e = emotions.map(\.rawValue).sorted().joined(separator: ",")
        return "\(score)|\(e)|\(tone.rawValue)"
    }
}
