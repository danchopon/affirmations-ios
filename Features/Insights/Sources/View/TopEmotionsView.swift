import SwiftUI
import CorePersistence
import DesignSystem

struct TopEmotionsView: View {
    let entries: [MoodEntry]

    private var topEmotions: [(Emotion, Int)] {
        var counts: [Emotion: Int] = [:]
        for entry in entries {
            for emotion in entry.emotionValues {
                counts[emotion, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top Emotions")
                .font(.appHeadline)

            if topEmotions.isEmpty {
                Text("No emotion data yet")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(topEmotions, id: \.0) { emotion, count in
                    HStack {
                        Text(emotion.emoji)
                            .font(.title3)
                        Text(emotion.displayName)
                            .font(.appBody)
                        Spacer()
                        Text("\(count)")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
