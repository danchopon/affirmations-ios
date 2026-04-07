import WidgetKit
import SwiftUI
import SwiftData
import CorePersistence

// MARK: - Entry

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let lastScore: Int?
}

// MARK: - Provider

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, streak: 7, lastScore: 8)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = makeEntry()
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: entry.date)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func makeEntry() -> StreakEntry {
        guard let container = makeSharedModelContainer() else {
            return StreakEntry(date: .now, streak: 0, lastScore: nil)
        }
        let context = ModelContext(container)
        let entries = (try? context.fetch(
            FetchDescriptor<MoodEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        )) ?? []
        let streak = StreakCalculator().currentStreak(from: entries)
        let lastScore = entries.first?.score
        return StreakEntry(date: .now, streak: streak, lastScore: lastScore)
    }
}

// MARK: - View

struct StreakWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("\(entry.streak)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(entry.streak == 1 ? "day" : "days")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()

            if let score = entry.lastScore {
                HStack(spacing: 4) {
                    Circle()
                        .fill(score.moodColor)
                        .frame(width: 10, height: 10)
                    Text("Mood \(score)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

// MARK: - Widget

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("Shows your current check-in streak and last mood score.")
        .supportedFamilies([.systemSmall])
    }
}
