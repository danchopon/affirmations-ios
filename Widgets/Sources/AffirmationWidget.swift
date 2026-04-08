import WidgetKit
import SwiftUI
import SwiftData
import CorePersistence

// MARK: - Entry

struct AffirmationEntry: TimelineEntry {
    let date: Date
    let text: String
}

// MARK: - Provider

struct AffirmationProvider: TimelineProvider {
    private let placeholder = "You are doing great. Keep going."

    func placeholder(in context: Context) -> AffirmationEntry {
        AffirmationEntry(date: .now, text: placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        let entry = makeEntry()
        let next = Calendar.current.date(byAdding: .hour, value: 6, to: entry.date)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func makeEntry() -> AffirmationEntry {
        guard let container = makeSharedModelContainer() else {
            return AffirmationEntry(date: .now, text: placeholder)
        }
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<Affirmation>(
            sortBy: [SortDescriptor(\.generatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let text = (try? context.fetch(descriptor))?.first?.text ?? placeholder
        return AffirmationEntry(date: .now, text: text)
    }
}

// MARK: - View

struct AffirmationWidgetView: View {
    let entry: AffirmationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.purple)
                Text("Affirmation")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(entry.text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(5)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

// MARK: - Widget

struct AffirmationWidget: Widget {
    let kind = "AffirmationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AffirmationProvider()) { entry in
            AffirmationWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Affirmation")
        .description("Shows your most recent affirmation.")
        .supportedFamilies([.systemMedium])
    }
}
