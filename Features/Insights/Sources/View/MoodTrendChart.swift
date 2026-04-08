import SwiftUI
import Charts
import CorePersistence
import DesignSystem

struct MoodTrendChart: View {
    let entries: [MoodEntry]

    @State private var selectedRange: TrendRange = .week
    @State private var rangeEndDate: Date = Calendar.current.startOfDay(for: .now)

    private let calendar = Calendar.current

    enum TrendRange: Int, CaseIterable, Identifiable {
        case week = 7
        case month = 30

        var id: Int { rawValue }

        var label: String {
            switch self {
            case .week: return "Week"
            case .month: return "Month"
            }
        }
    }

    private struct DayAverage: Identifiable {
        var id: Date { date }
        let date: Date
        let average: Double
    }

    // MARK: - Date range

    private var rangeStartDate: Date {
        calendar.date(byAdding: .day, value: -(selectedRange.rawValue - 1), to: rangeEndDate)!
    }

    private var isAtPresent: Bool {
        rangeEndDate >= calendar.startOfDay(for: .now)
    }

    private var rangeLabel: String {
        let start = rangeStartDate
        let end = rangeEndDate
        let df = DateFormatter()

        let startMonth = calendar.component(.month, from: start)
        let endMonth = calendar.component(.month, from: end)
        let startDay = calendar.component(.day, from: start)
        let endDay = calendar.component(.day, from: end)

        if selectedRange == .week && startMonth == endMonth {
            df.dateFormat = "MMMM"
            let monthName = df.string(from: start)
            return "\(monthName) \(startDay)-\(endDay)"
        } else {
            df.dateFormat = "d MMM"
            return "\(df.string(from: start)) - \(df.string(from: end))"
        }
    }

    // MARK: - Filtered data

    private var filteredDays: [DayAverage] {
        let start = rangeStartDate
        let end = calendar.date(byAdding: .day, value: 1, to: rangeEndDate)!

        var map: [Date: [Int]] = [:]
        for entry in entries where entry.date >= start && entry.date < end {
            let day = calendar.startOfDay(for: entry.date)
            map[day, default: []].append(entry.score)
        }

        return map
            .map { DayAverage(date: $0.key, average: Double($0.value.reduce(0, +)) / Double($0.value.count)) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - X-axis helpers

    private func weekdayLabel(for date: Date) -> String {
        let day = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)
        let short = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        return "\(day) \(short[weekday - 1])"
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title + picker
            HStack {
                Text("Mood Trend")
                    .font(.appHeadline)
                Spacer()
                Picker("Range", selection: $selectedRange) {
                    ForEach(TrendRange.allCases) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
                .onChange(of: selectedRange) { _, _ in
                    rangeEndDate = calendar.startOfDay(for: .now)
                }
            }

            // Date range navigation
            HStack {
                Button {
                    rangeEndDate = calendar.date(byAdding: .day, value: -selectedRange.rawValue, to: rangeEndDate)!
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.appCaption)
                        .foregroundStyle(Color.appPrimary)
                }

                Spacer()

                Text(rangeLabel)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    rangeEndDate = min(
                        calendar.date(byAdding: .day, value: selectedRange.rawValue, to: rangeEndDate)!,
                        calendar.startOfDay(for: .now)
                    )
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.appCaption)
                        .foregroundStyle(isAtPresent ? Color.secondary.opacity(0.3) : Color.appPrimary)
                }
                .disabled(isAtPresent)
            }

            // Chart
            if filteredDays.isEmpty {
                Text("Not enough data yet")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
            } else {
                chart
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .animation(.easeInOut(duration: 0.25), value: selectedRange)
        .animation(.easeInOut(duration: 0.25), value: rangeEndDate)
    }

    @ViewBuilder
    private var chart: some View {
        Chart(filteredDays) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Score", point.average)
            )
            .foregroundStyle(Color.appPrimary)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Date", point.date),
                y: .value("Score", point.average)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.appPrimary.opacity(0.25), Color.appPrimary.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Date", point.date),
                y: .value("Score", point.average)
            )
            .foregroundStyle(Color.appPrimary)
            .symbolSize(filteredDays.count < 3 ? 40 : 20)
        }
        .chartYScale(domain: 1...10)
        .chartXScale(domain: rangeStartDate...calendar.date(byAdding: .day, value: 1, to: rangeEndDate)!)
        .chartXAxis {
            if selectedRange == .week {
                AxisMarks(values: .stride(by: .day, count: 1)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(weekdayLabel(for: date))
                                .font(.appCaption)
                        }
                    }
                }
            } else {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.day().month(.abbreviated))
                                .font(.appCaption)
                        }
                    }
                }
            }
        }
        .frame(height: 160)
    }
}
