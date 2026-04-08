import WidgetKit
import SwiftUI
import SwiftData
import CorePersistence

// MARK: - Entry

struct CheckInEntry: TimelineEntry {
    let date: Date
    let lastCheckInDate: Date?
}

// MARK: - Provider

struct CheckInProvider: TimelineProvider {
    func placeholder(in context: Context) -> CheckInEntry {
        CheckInEntry(date: .now, lastCheckInDate: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (CheckInEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CheckInEntry>) -> Void) {
        let entry = makeEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: entry.date)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func makeEntry() -> CheckInEntry {
        guard let container = makeSharedModelContainer() else {
            return CheckInEntry(date: .now, lastCheckInDate: nil)
        }
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let lastDate = (try? context.fetch(descriptor))?.first?.date
        return CheckInEntry(date: .now, lastCheckInDate: lastDate)
    }
}

// MARK: - View

struct CheckInWidgetView: View {
    let entry: CheckInEntry

    private var timeSinceLabel: String {
        guard let last = entry.lastCheckInDate else { return "No check-ins yet" }
        let calendar = Calendar.current
        if calendar.isDateInToday(last) {
            return "Checked in today"
        }
        if calendar.isDateInYesterday(last) {
            return "Last: yesterday"
        }
        let days = calendar.dateComponents([.day], from: last, to: entry.date).day ?? 0
        return "Last: \(days)d ago"
    }

    private var checkedInToday: Bool {
        guard let last = entry.lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: checkedInToday ? "checkmark.circle.fill" : "plus.circle.fill")
                    .foregroundStyle(checkedInToday ? .green : .purple)
                Text(checkedInToday ? "Done" : "Check in")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(checkedInToday ? "Great job!" : "How are you?")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            Text(timeSinceLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

// MARK: - Widget

struct CheckInWidget: Widget {
    let kind = "CheckInWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CheckInProvider()) { entry in
            CheckInWidgetView(entry: entry)
        }
        .configurationDisplayName("Check In")
        .description("Quick reminder to log your mood.")
        .supportedFamilies([.systemSmall])
    }
}
