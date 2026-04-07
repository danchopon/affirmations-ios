import Foundation

/// Client-side rate limiter. Tracks free tier daily quota and per-minute burst limit.
final class AIRateLimiter: @unchecked Sendable {
    private let freeDaily: Int
    private let burstPerMinute: Int
    private let defaults: UserDefaults

    private var minuteTimestamps: [Date] = []

    private let dailyCountKey = "ai.daily.count"
    private let dailyDateKey = "ai.daily.date"

    init(freeDaily: Int = 3, burstPerMinute: Int = 5, defaults: UserDefaults = .standard) {
        self.freeDaily = freeDaily
        self.burstPerMinute = burstPerMinute
        self.defaults = defaults
    }

    var remainingFreeToday: Int {
        let count = todayCount
        return max(0, freeDaily - count)
    }

    /// Returns true and increments counters if the request is allowed.
    func allow(isPremium: Bool) -> Bool {
        let now = Date.now

        // Burst check (always enforced)
        minuteTimestamps = minuteTimestamps.filter { now.timeIntervalSince($0) < 60 }
        guard minuteTimestamps.count < burstPerMinute else { return false }

        // Free tier daily quota
        if !isPremium {
            guard remainingFreeToday > 0 else { return false }
            incrementDailyCount()
        }

        minuteTimestamps.append(now)
        return true
    }

    // MARK: - Private

    private var todayCount: Int {
        guard let stored = defaults.string(forKey: dailyDateKey),
              stored == todayString else {
            return 0
        }
        return defaults.integer(forKey: dailyCountKey)
    }

    private func incrementDailyCount() {
        let today = todayString
        if defaults.string(forKey: dailyDateKey) != today {
            defaults.set(today, forKey: dailyDateKey)
            defaults.set(1, forKey: dailyCountKey)
        } else {
            defaults.set(defaults.integer(forKey: dailyCountKey) + 1, forKey: dailyCountKey)
        }
    }

    private var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: .now)
    }
}
