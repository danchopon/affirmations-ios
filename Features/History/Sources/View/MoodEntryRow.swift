import SwiftUI
import CorePersistence
import DesignSystem

struct MoodEntryRow: View {
    let entry: MoodEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(entry.score.moodColor)
                    .frame(width: 44, height: 44)
                Text("\(entry.score)")
                    .font(.appHeadline)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if !entry.emotionValues.isEmpty {
                        Text(entry.emotionValues.prefix(4).map(\.emoji).joined())
                            .font(.appBody)
                    }
                    Spacer()
                    Text(entry.date, format: .dateTime.hour().minute())
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }

                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
