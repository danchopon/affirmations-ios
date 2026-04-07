import Foundation
import CorePersistence

/// Builds a compact summary of recent MoodEntry records for the AI prompt.
/// Sends ~3 lines of context instead of 7 full entries -- saves ~80% tokens.
public struct RecentMoodSummaryBuilder {
    public init() {}

    public func build(from entries: [MoodEntry], days: Int = 7) -> RecentMoodSummary? {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: .now)!
        let recent = entries.filter { $0.date >= cutoff }
        guard !recent.isEmpty else { return nil }

        let scores = recent.map(\.score)
        let average = Double(scores.reduce(0, +)) / Double(scores.count)
        let trend = computeTrend(scores: scores)
        let topEmotions = topThreeEmotions(from: recent)

        return RecentMoodSummary(
            averageScore: average,
            topEmotions: topEmotions,
            trend: trend,
            dayCount: recent.count
        )
    }

    private func computeTrend(scores: [Int]) -> MoodTrend {
        guard scores.count >= 3 else { return .stable }
        let half = scores.count / 2
        let firstHalf = scores.prefix(half)
        let secondHalf = scores.suffix(half)
        let firstAvg = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
        let secondAvg = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)
        let diff = secondAvg - firstAvg
        if diff > 0.5 { return .improving }
        if diff < -0.5 { return .declining }
        return .stable
    }

    private func topThreeEmotions(from entries: [MoodEntry]) -> [Emotion] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for e in entry.emotions { counts[e, default: 0] += 1 }
        }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .compactMap { Emotion(rawValue: $0.key) }
    }
}
