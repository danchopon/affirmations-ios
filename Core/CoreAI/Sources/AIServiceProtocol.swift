import Foundation
import CorePersistence

// MARK: - Context sent to AI

public struct AffirmationContext: Sendable {
    public let currentScore: Int
    public let emotions: [Emotion]
    public let tone: ToneType
    public let language: String
    /// Summary of recent history, NOT raw entries (keeps token cost low).
    public let recentSummary: RecentMoodSummary?

    public init(
        currentScore: Int,
        emotions: [Emotion],
        tone: ToneType,
        language: String = "en",
        recentSummary: RecentMoodSummary? = nil
    ) {
        self.currentScore = currentScore
        self.emotions = emotions
        self.tone = tone
        self.language = language
        self.recentSummary = recentSummary
    }
}

public struct RecentMoodSummary: Sendable {
    public let averageScore: Double
    public let topEmotions: [Emotion]
    public let trend: MoodTrend
    public let dayCount: Int

    public init(averageScore: Double, topEmotions: [Emotion], trend: MoodTrend, dayCount: Int) {
        self.averageScore = averageScore
        self.topEmotions = topEmotions
        self.trend = trend
        self.dayCount = dayCount
    }
}

public enum MoodTrend: String, Sendable {
    case improving
    case stable
    case declining
}

// MARK: - Errors

public enum AIServiceError: Error, Sendable {
    case rateLimitExceeded
    case networkUnavailable
    case apiError(statusCode: Int, message: String)
    case invalidResponse
}

// MARK: - Protocol

public protocol AIServiceProtocol: Sendable {
    func generateAffirmation(context: AffirmationContext) async throws -> String
    func remainingFreeRequests() async -> Int
}
