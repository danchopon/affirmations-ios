import SwiftUI
import SwiftData
import CorePersistence
import CoreAnalytics
import DesignSystem

public struct HistoryView: View {
    @Environment(\.analytics) private var analytics
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var displayedMonth: Date = {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: .now)
        return cal.date(from: comps) ?? .now
    }()
    @State private var selectedDay: Date?

    public init() {}

    private var entriesInMonth: [MoodEntry] {
        guard let interval = Calendar.current.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }
        return entries.filter { interval.contains($0.date) }
    }

    private var displayedEntries: [MoodEntry] {
        guard let day = selectedDay else { return entriesInMonth }
        return entries.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    private var sectionTitle: String {
        guard let day = selectedDay else { return "This Month" }
        return day.formatted(.dateTime.month().day())
    }

    public var body: some View {
        List {
            Section {
                MoodCalendarGrid(
                    entries: entries,
                    displayedMonth: $displayedMonth,
                    selectedDay: $selectedDay
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section(sectionTitle) {
                if displayedEntries.isEmpty {
                    Text("No check-ins")
                        .foregroundStyle(.secondary)
                        .font(.appCaption)
                } else {
                    ForEach(displayedEntries) { entry in
                        MoodEntryRow(entry: entry)
                    }
                    .onDelete { offsets in
                        deleteEntries(at: offsets, from: displayedEntries)
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            analytics.track(HistoryEvent.viewed)
        }
        .onChange(of: selectedDay) { _, newValue in
            if newValue != nil {
                analytics.track(HistoryEvent.daySelected)
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet, from source: [MoodEntry]) {
        for index in offsets {
            modelContext.delete(source[index])
            analytics.track(HistoryEvent.entryDeleted)
        }
    }
}
