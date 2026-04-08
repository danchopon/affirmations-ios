import WidgetKit
import SwiftUI
import SwiftData
import CorePersistence
import DesignSystem

// MARK: - Entry

struct WeeklyMoodEntry: TimelineEntry {
    let date: Date
    /// Scores for Mon..Sun (index 0 = Monday). nil means no check-in that day.
    let scores: [Int?]
}

// MARK: - Provider

struct WeeklyMoodProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeeklyMoodEntry {
        WeeklyMoodEntry(date: .now, scores: [7, 6, 8, nil, 5, 9, nil])
    }

    func getSnapshot(in context: Context, completion: @escaping (WeeklyMoodEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklyMoodEntry>) -> Void) {
        let entry = makeEntry()
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: entry.date)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func makeEntry() -> WeeklyMoodEntry {
        guard let container = makeSharedModelContainer() else {
            return WeeklyMoodEntry(date: .now, scores: Array(repeating: nil, count: 7))
        }
        let context = ModelContext(container)

        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday

        // Find start of current week (Monday)
        let today = calendar.startOfDay(for: .now)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday)!

        let entries = (try? context.fetch(
            FetchDescriptor<MoodEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        )) ?? []

        // Build per-day averages Mon(0)..Sun(6)
        var dayScores: [[Int]] = Array(repeating: [], count: 7)
        for entry in entries where entry.date >= monday && entry.date < nextMonday {
            let entryWeekday = calendar.component(.weekday, from: entry.date)
            let index = (entryWeekday + 5) % 7
            dayScores[index].append(entry.score)
        }

        let scores: [Int?] = dayScores.map { scores in
            scores.isEmpty ? nil : scores.reduce(0, +) / scores.count
        }

        return WeeklyMoodEntry(date: .now, scores: scores)
    }
}

// MARK: - View

struct WeeklyMoodWidgetView: View {
    let entry: WeeklyMoodEntry

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    private var todayIndex: Int {
        let weekday = Calendar.current.component(.weekday, from: entry.date)
        return (weekday + 5) % 7
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.purple)
                Text("This Week")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 4) {
                        moodDot(for: entry.scores[index], isToday: index == todayIndex)
                        Text(dayLabels[index])
                            .font(.system(size: 10, weight: index == todayIndex ? .bold : .regular))
                            .foregroundStyle(index == todayIndex ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }

    @ViewBuilder
    private func moodDot(for score: Int?, isToday: Bool) -> some View {
        if let score {
            RoundedRectangle(cornerRadius: 3)
                .fill(score.moodColor)
                .frame(height: barHeight(for: score))
        } else if isToday {
            Circle()
                .strokeBorder(Color.purple.opacity(0.4), lineWidth: 1.5)
                .frame(width: 14, height: 14)
        } else {
            Circle()
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 8, height: 8)
        }
    }

    private func barHeight(for score: Int) -> CGFloat {
        let normalized = CGFloat(max(1, min(10, score)) - 1) / 9.0
        return 8 + normalized * 28
    }
}

// MARK: - Widget

struct WeeklyMoodWidget: Widget {
    let kind = "WeeklyMoodWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeeklyMoodProvider()) { entry in
            WeeklyMoodWidgetView(entry: entry)
        }
        .configurationDisplayName("Weekly Mood")
        .description("See your mood for each day this week.")
        .supportedFamilies([.systemMedium])
    }
}
