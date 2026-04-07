import Foundation
import OSLog
import CorePersistence

private let logger = Logger(subsystem: "com.affirmations", category: "AI")

/// Calls the Anthropic Messages API via a backend proxy.
/// API key is NEVER stored in the app -- proxy holds it.
public final class AnthropicAIService: AIServiceProtocol, @unchecked Sendable {
    private let proxyURL: URL
    private let rateLimiter: AIRateLimiter
    private let cache: AIResponseCache
    private let isPremium: () -> Bool

    public var remainingFreeRequests: Int {
        rateLimiter.remainingFreeToday
    }

    public init(
        proxyURL: URL,
        isPremium: @escaping @Sendable () -> Bool = { false }
    ) {
        self.proxyURL = proxyURL
        self.rateLimiter = AIRateLimiter()
        self.cache = AIResponseCache()
        self.isPremium = isPremium
    }

    public func generateAffirmation(context: AffirmationContext) async throws -> String {
        // Cache hit
        if let cached = cache.get(score: context.currentScore, emotions: context.emotions, tone: context.tone) {
            logger.debug("Cache hit for score=\(context.currentScore)")
            return cached
        }

        // Rate limit check
        guard rateLimiter.allow(isPremium: isPremium()) else {
            throw AIServiceError.rateLimitExceeded
        }

        let prompt = buildPrompt(context: context)
        let result = try await requestWithRetry(prompt: prompt, model: "claude-haiku-4-5")

        cache.set(text: result, score: context.currentScore, emotions: context.emotions, tone: context.tone)
        return result
    }

    // MARK: - Private

    private func requestWithRetry(prompt: String, model: String) async throws -> String {
        var lastError: Error?
        let delays: [TimeInterval] = [1, 2, 4]

        for (attempt, delay) in delays.enumerated() {
            do {
                return try await request(prompt: prompt, model: model)
            } catch AIServiceError.apiError(let code, _) where code == 429 {
                logger.warning("Rate limited by API, attempt=\(attempt + 1)")
                if attempt < delays.count - 1 {
                    try await Task.sleep(for: .seconds(delay))
                }
                lastError = AIServiceError.apiError(statusCode: 429, message: "Rate limited")
            } catch AIServiceError.apiError(let code, _) where code >= 500 {
                logger.error("Server error code=\(code), attempt=\(attempt + 1)")
                if attempt < delays.count - 1 {
                    try await Task.sleep(for: .seconds(delay))
                }
                lastError = AIServiceError.apiError(statusCode: code, message: "Server error")
            } catch {
                throw error
            }
        }
        throw lastError ?? AIServiceError.invalidResponse
    }

    private func request(prompt: String, model: String) async throws -> String {
        var req = URLRequest(url: proxyURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 300,
            "messages": [["role": "user", "content": prompt]]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let start = Date.now
        let (data, response) = try await URLSession.shared.data(for: req)
        let duration = Date.now.timeIntervalSince(start)
        logger.debug("AI request completed in \(duration, format: .fixed(precision: 2))s")

        guard let http = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        guard http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? ""
            throw AIServiceError.apiError(statusCode: http.statusCode, message: msg)
        }

        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = (json["content"] as? [[String: Any]])?.first,
            let text = content["text"] as? String
        else {
            throw AIServiceError.invalidResponse
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func buildPrompt(context: AffirmationContext) -> String {
        let emotionList = context.emotions.map(\.displayName).joined(separator: ", ")
        let toneInstruction: String
        switch context.tone {
        case .motivational:
            toneInstruction = "energizing, action-oriented, and empowering"
        case .gentle:
            toneInstruction = "soft, nurturing, compassionate, and kind"
        case .spiritual:
            toneInstruction = "grounded, mindful, and introspective"
        }

        var prompt = """
        Write a single personal affirmation (2-3 sentences, no quotes) in \(context.language) for someone who:
        - Feels \(emotionList.isEmpty ? "neutral" : emotionList)
        - Rated their mood \(context.currentScore)/10
        The tone should be \(toneInstruction).
        """

        if let summary = context.recentSummary {
            prompt += """

        Recent context (\(summary.dayCount) days): average mood \(String(format: "%.1f", summary.averageScore))/10, \
        trend is \(summary.trend.rawValue).
        """
        }

        prompt += "\nRespond with ONLY the affirmation text, nothing else."
        return prompt
    }
}

// MARK: - Factory

public extension AIService {
    static var live: any AIServiceProtocol {
        // Replace with your actual proxy URL.
        // The proxy forwards requests to Anthropic and holds the API key server-side.
        let proxyURL = URL(string: "https://api.yourproxy.com/v1/affirmations")!
        return AnthropicAIService(proxyURL: proxyURL)
    }
}

/// Namespace for factory methods.
public enum AIService {}
