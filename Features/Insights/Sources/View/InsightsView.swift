import SwiftUI
import SwiftData
import CorePersistence
import CoreAnalytics
import DesignSystem

public struct InsightsView: View {
    @Environment(\.analytics) private var analytics
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    private let streakCalc = StreakCalculator()
    private let calendar = Calendar.current

    public init() {}

    // MARK: - Computed stats

    private var currentStreak: Int {
        streakCalc.currentStreak(from: entries)
    }

    private var totalCheckIns: Int {
        streakCalc.totalCheckinDays(from: entries)
    }

    private var weeklyAverage: Double? {
        let cutoff = calendar.date(byAdding: .day, value: -7, to: .now)!
        let recent = entries.filter { $0.date >= cutoff }
        guard !recent.isEmpty else { return nil }
        return Double(recent.map(\.score).reduce(0, +)) / Double(recent.count)
    }

    private var monthlyAverage: Double? {
        guard let interval = calendar.dateInterval(of: .month, for: .now) else { return nil }
        let thisMonth = entries.filter { interval.contains($0.date) }
        guard !thisMonth.isEmpty else { return nil }
        return Double(thisMonth.map(\.score).reduce(0, +)) / Double(thisMonth.count)
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                HStack(spacing: 12) {
                    StatCard(
                        title: "Streak",
                        value: "\(currentStreak)",
                        subtitle: currentStreak == 1 ? "day" : "days"
                    )
                    StatCard(
                        title: "Total Days",
                        value: "\(totalCheckIns)",
                        subtitle: "checked in"
                    )
                }

                HStack(spacing: 12) {
                    if let avg = weeklyAverage {
                        StatCard(
                            title: "This Week",
                            value: String(format: "%.1f", avg),
                            subtitle: "avg mood"
                        )
                    } else {
                        StatCard(title: "This Week", value: "—", subtitle: "avg mood")
                    }

                    if let avg = monthlyAverage {
                        StatCard(
                            title: "This Month",
                            value: String(format: "%.1f", avg),
                            subtitle: "avg mood"
                        )
                    } else {
                        StatCard(title: "This Month", value: "—", subtitle: "avg mood")
                    }
                }

                MoodTrendChart(entries: entries)

                TopEmotionsView(entries: entries)
            }
            .padding()
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            analytics.track(InsightsEvent.viewed)
        }
    }
}
