import WidgetKit
import SwiftUI
import SwiftData
import CorePersistence

// MARK: - Entry

struct TopEmotionEntry: TimelineEntry {
    let date: Date
    let emotion: Emotion?
    let count: Int
}

// MARK: - Provider

struct TopEmotionProvider: TimelineProvider {
    func placeholder(in context: Context) -> TopEmotionEntry {
        TopEmotionEntry(date: .now, emotion: .happy, count: 5)
    }

    func getSnapshot(in context: Context, completion: @escaping (TopEmotionEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TopEmotionEntry>) -> Void) {
        let entry = makeEntry()
        let next = Calendar.current.date(byAdding: .hour, value: 2, to: entry.date)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func makeEntry() -> TopEmotionEntry {
        guard let container = makeSharedModelContainer() else {
            return TopEmotionEntry(date: .now, emotion: nil, count: 0)
        }
        let context = ModelContext(container)

        // Last 7 days
        let cutoff = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: .now))!
        let entries = (try? context.fetch(
            FetchDescriptor<MoodEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        )) ?? []

        var counts: [Emotion: Int] = [:]
        for entry in entries where entry.date >= cutoff {
            for emotion in entry.emotionValues {
                counts[emotion, default: 0] += 1
            }
        }

        guard let top = counts.max(by: { $0.value < $1.value }) else {
            return TopEmotionEntry(date: .now, emotion: nil, count: 0)
        }

        return TopEmotionEntry(date: .now, emotion: top.key, count: top.value)
    }
}

// MARK: - View

struct TopEmotionWidgetView: View {
    let entry: TopEmotionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                Text("Top Emotion")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let emotion = entry.emotion {
                Text(emotion.emoji)
                    .font(.system(size: 36))

                Text(emotion.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("\(entry.count)x this week")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("--")
                    .font(.system(size: 36))
                Text("No data yet")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

// MARK: - Widget

struct TopEmotionWidget: Widget {
    let kind = "TopEmotionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TopEmotionProvider()) { entry in
            TopEmotionWidgetView(entry: entry)
        }
        .configurationDisplayName("Top Emotion")
        .description("Your most frequent emotion this week.")
        .supportedFamilies([.systemSmall])
    }
}
