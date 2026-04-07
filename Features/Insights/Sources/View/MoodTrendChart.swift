import SwiftUI
import Charts
import CorePersistence
import DesignSystem

struct MoodTrendChart: View {
    let entries: [MoodEntry]

    private struct DayAverage: Identifiable {
        let id = UUID()
        let date: Date
        let average: Double
    }

    private var last30Days: [DayAverage] {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: .now))!

        var map: [Date: [Int]] = [:]
        for entry in entries where entry.date >= cutoff {
            let day = calendar.startOfDay(for: entry.date)
            map[day, default: []].append(entry.score)
        }

        return map
            .map { DayAverage(date: $0.key, average: Double($0.value.reduce(0, +)) / Double($0.value.count)) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood Trend (30 days)")
                .font(.appHeadline)

            if last30Days.isEmpty {
                Text("Not enough data yet")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .frame(height: 120)
            } else {
                Chart(last30Days) { point in
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
                }
                .chartYScale(domain: 1...10)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .font(.appCaption)
                    }
                }
                .frame(height: 140)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
