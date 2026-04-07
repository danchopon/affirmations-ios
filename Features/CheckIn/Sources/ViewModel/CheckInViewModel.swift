import Foundation
import Observation
import OSLog
import SwiftData
import CoreAnalytics
import CorePersistence
import CoreAI

private let logger = Logger(subsystem: "com.affirmations", category: "CheckIn")

@Observable
@MainActor
public final class CheckInViewModel {
    // MARK: - State

    public var selectedScore: Int = 5
    public var selectedEmotions: Set<Emotion> = []
    public var note: String = ""
    public var currentStep: CheckInStep = .moodScore
    public var isGeneratingAffirmation: Bool = false
    public var generatedAffirmation: String?
    public var errorMessage: String?

    private var hasCompleted = false

    // MARK: - Dependencies

    private let analytics: any AnalyticsServiceProtocol
    private let aiService: any AIServiceProtocol
    private let modelContext: ModelContext
    private let summaryBuilder = RecentMoodSummaryBuilder()

    private let startDate = Date.now

    public init(
        analytics: any AnalyticsServiceProtocol,
        aiService: any AIServiceProtocol,
        modelContext: ModelContext
    ) {
        self.analytics = analytics
        self.aiService = aiService
        self.modelContext = modelContext
    }

    // MARK: - Actions

    public func onAppear() {
        analytics.track(CheckInEvent.started)
    }

    public func selectScore(_ score: Int) {
        selectedScore = score
        analytics.track(CheckInEvent.moodScoreSelected(score: score))
    }

    public func toggleEmotion(_ emotion: Emotion) {
        if selectedEmotions.contains(emotion) {
            selectedEmotions.remove(emotion)
        } else {
            selectedEmotions.insert(emotion)
        }
    }

    public func proceedFromEmotions() {
        analytics.track(CheckInEvent.emotionsSelected(emotions: Array(selectedEmotions)))
        currentStep = .note
    }

    public func completeCheckIn(userProfile: UserProfile?) async {
        guard !hasCompleted else { return }
        hasCompleted = true

        let duration = Date.now.timeIntervalSince(startDate)

        // 1. Save MoodEntry immediately -- offline-first
        let entry = MoodEntry(
            score: selectedScore,
            note: note.isEmpty ? nil : note,
            emotions: Array(selectedEmotions),
            checkinDuration: duration
        )
        modelContext.insert(entry)
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save MoodEntry: \(error)")
            errorMessage = "Could not save your check-in. Please try again."
            hasCompleted = false
            return
        }

        analytics.track(CheckInEvent.completed(
            score: selectedScore,
            emotionCount: selectedEmotions.count,
            durationSeconds: duration,
            hasNote: !note.isEmpty
        ))

        // 2. Generate affirmation asynchronously (non-blocking)
        await generateAffirmation(for: entry, profile: userProfile)
    }

    public func abandonCheckIn() {
        let duration = Date.now.timeIntervalSince(startDate)
        analytics.track(CheckInEvent.abandoned(atStep: currentStep, durationSeconds: duration))
    }

    // MARK: - Private

    private func generateAffirmation(for entry: MoodEntry, profile: UserProfile?) async {
        let tone = profile?.preferredToneValue ?? .gentle
        guard let profile, profile.aiConsentGranted else {
            generatedAffirmation = await fallback(score: entry.score, tone: tone)
            return
        }

        isGeneratingAffirmation = true
        errorMessage = nil

        let recentEntries = (try? modelContext.fetch(FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )))?.prefix(20).map { $0 } ?? []

        let summary = summaryBuilder.build(from: recentEntries)
        let context = AffirmationContext(
            currentScore: entry.score,
            emotions: entry.emotionValues,
            tone: profile.preferredToneValue,
            language: profile.language,
            recentSummary: summary
        )

        do {
            let text = try await aiService.generateAffirmation(context: context)
            let affirmation = Affirmation(text: text, tone: profile.preferredToneValue)
            entry.affirmation = affirmation
            do {
                try modelContext.save()
            } catch {
                logger.error("Failed to save Affirmation: \(error)")
            }
            generatedAffirmation = text
        } catch AIServiceError.rateLimitExceeded {
            generatedAffirmation = await fallback(score: entry.score, tone: profile.preferredToneValue)
            errorMessage = "Daily AI limit reached. Showing an offline affirmation."
        } catch {
            generatedAffirmation = await fallback(score: entry.score, tone: profile.preferredToneValue)
        }

        isGeneratingAffirmation = false
    }

    private func fallback(score: Int, tone: ToneType) async -> String {
        let ctx = AffirmationContext(currentScore: score, emotions: [], tone: tone)
        return (try? await LocalAffirmationService().generateAffirmation(context: ctx)) ?? "You are doing great."
    }
}
