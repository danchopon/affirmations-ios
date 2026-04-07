import Foundation

/// Computes streak and check-in stats from MoodEntry records.
/// These are never stored in the database to avoid stale derived data.
public struct StreakCalculator {
    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Returns the current streak -- consecutive days with at least one check-in ending today or yesterday.
    public func currentStreak(from entries: [MoodEntry]) -> Int {
        let days = uniqueDays(from: entries)
        guard !days.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: .now)
        var streak = 0
        var check = today

        for day in days.sorted(by: >) {
            let diff = calendar.dateComponents([.day], from: day, to: check).day ?? 0
            if diff == 0 {
                streak += 1
                check = calendar.date(byAdding: .day, value: -1, to: check)!
            } else if diff == 1 && streak == 0 {
                // Gap today is ok if we haven't started yet (check-in yesterday counts)
                streak += 1
                check = calendar.date(byAdding: .day, value: -1, to: day)!
            } else {
                break
            }
        }

        return streak
    }

    /// Total number of unique days with at least one check-in.
    public func totalCheckinDays(from entries: [MoodEntry]) -> Int {
        uniqueDays(from: entries).count
    }

    private func uniqueDays(from entries: [MoodEntry]) -> Set<Date> {
        Set(entries.map { calendar.startOfDay(for: $0.date) })
    }
}
