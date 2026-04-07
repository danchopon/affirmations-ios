import Foundation
import CorePersistence

/// Offline fallback. Returns a random affirmation from a curated local pool.
/// Used when: no network, free tier exhausted, or AI consent not granted.
public final class LocalAffirmationService: AIServiceProtocol, @unchecked Sendable {
    public var remainingFreeRequests: Int { Int.max }

    public init() {}

    public func generateAffirmation(context: AffirmationContext) async throws -> String {
        let pool = affirmations(for: context.tone, score: context.currentScore)
        return pool.randomElement() ?? "You are enough, exactly as you are."
    }

    private func affirmations(for tone: ToneType, score: Int) -> [String] {
        switch tone {
        case .motivational:
            if score <= 4 {
                return [
                    "Every difficult moment is building your strength. You have survived 100% of your hard days.",
                    "Your resilience is extraordinary. Keep going -- the next step is all that matters.",
                    "You are stronger than you feel right now. Tomorrow holds new possibilities."
                ]
            }
            return [
                "You are doing great things. Trust the momentum you have already built.",
                "Your energy and effort are creating real change. Keep moving forward.",
                "You have what it takes. Today is another opportunity to show up fully."
            ]
        case .gentle:
            if score <= 4 {
                return [
                    "It is okay not to be okay. Be gentle with yourself today.",
                    "You deserve the same kindness you give to others. Rest if you need to.",
                    "Your feelings are valid. You do not have to rush to feel better."
                ]
            }
            return [
                "You are worthy of love and care simply because you exist.",
                "Taking care of yourself is not selfish. It is how you sustain your light.",
                "You are doing beautifully. Allow yourself to receive today's goodness."
            ]
        case .spiritual:
            if score <= 4 {
                return [
                    "In stillness, you find what endures. Breathe. You are held.",
                    "Even the darkest night gives way to dawn. Trust the process of your becoming.",
                    "Every experience is part of your path. You are exactly where you need to be."
                ]
            }
            return [
                "You are connected to something greater. Your presence matters.",
                "Gratitude opens doors that effort cannot. Notice three things that are good right now.",
                "Peace is not the absence of difficulty -- it is the presence of grace. You carry it."
            ]
        }
    }
}
