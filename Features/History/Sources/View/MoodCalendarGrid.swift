import SwiftUI
import CorePersistence
import DesignSystem

struct MoodCalendarGrid: View {
    let entries: [MoodEntry]
    @Binding var displayedMonth: Date
    @Binding var selectedDay: Date?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    private var weekdaySymbols: [String] {
        // Rotate veryShortWeekdaySymbols so the calendar's firstWeekday is leftmost.
        var symbols = calendar.veryShortWeekdaySymbols  // index 0 = Sunday
        let offset = calendar.firstWeekday - 1
        return Array(symbols[offset...] + symbols[..<offset])
    }

    private var scoresByDay: [Date: Double] {
        var map: [Date: [Int]] = [:]
        for entry in entries {
            let day = calendar.startOfDay(for: entry.date)
            map[day, default: []].append(entry.score)
        }
        return map.mapValues { Double($0.reduce(0, +)) / Double($0.count) }
    }

    private var daysInMonth: [Date?] {
        guard
            let range = calendar.range(of: .day, in: .month, for: displayedMonth),
            let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))
        else { return [] }

        let rawWeekday = calendar.component(.weekday, from: firstDay)       // 1 = Sun
        let offset = (rawWeekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }

    private var canAdvanceMonth: Bool {
        let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        return next <= .now
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.appPrimary)
                }

                Spacer()

                Text(displayedMonth, format: .dateTime.month(.wide).year())
                    .font(.appHeadline)

                Spacer()

                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(canAdvanceMonth ? Color.appPrimary : Color.secondary.opacity(0.3))
                }
                .disabled(!canAdvanceMonth)
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date {
                        DayCell(
                            date: date,
                            avgScore: scoresByDay[calendar.startOfDay(for: date)],
                            isSelected: selectedDay.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                            isToday: calendar.isDateInToday(date)
                        )
                        .onTapGesture {
                            let day = calendar.startOfDay(for: date)
                            selectedDay = selectedDay.map { calendar.isDate($0, inSameDayAs: date) } == true ? nil : day
                        }
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct DayCell: View {
    let date: Date
    let avgScore: Double?
    let isSelected: Bool
    let isToday: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(avgScore.map { Int($0.rounded()).moodColor } ?? Color.clear)
            Circle()
                .strokeBorder(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            Circle()
                .strokeBorder(isToday && !isSelected ? Color.secondary.opacity(0.35) : Color.clear, lineWidth: 1)

            Text("\(Calendar.current.component(.day, from: date))")
                .font(.appCaption)
                .foregroundStyle(avgScore != nil ? Color.white : Color.primary)
        }
        .frame(height: 36)
    }
}
