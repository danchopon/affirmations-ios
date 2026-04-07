import SwiftUI
import SwiftData
import CorePersistence

/// Shown before the first AI-powered affirmation.
/// Explains exactly what data leaves the device and lets the user opt in or out.
public struct AIConsentView: View {
    let onAccept: () -> Void
    let onDecline: () -> Void

    public init(onAccept: @escaping () -> Void, onDecline: @escaping () -> Void) {
        self.onAccept = onAccept
        self.onDecline = onDecline
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(.purple)

                Text("AI Affirmations")
                    .font(.title2.bold())

                Text("Personalized affirmations powered by AI")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 16) {
                Label("What is sent to the AI", systemImage: "arrow.up.circle")
                    .font(.headline)

                dataRow(icon: "dial.medium", label: "Your mood score (e.g. 7/10)")
                dataRow(icon: "face.smiling", label: "Selected emotions (e.g. calm, hopeful)")
                dataRow(icon: "chart.line.uptrend.xyaxis", label: "Recent mood trend (average, improving/declining)")

                Divider()

                Label("What is never sent", systemImage: "nosign")
                    .font(.headline)

                dataRow(icon: "note.text", label: "Your personal notes", crossed: true)
                dataRow(icon: "person", label: "Your name or account info", crossed: true)
            }
            .padding()
            .background(.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("Data is processed by Anthropic. You can opt out any time in Settings.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                Button("Enable AI Affirmations") {
                    onAccept()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("No thanks, use offline only") {
                    onDecline()
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    private func dataRow(icon: String, label: String, crossed: Bool = false) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(crossed ? .red : .green)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
                .strikethrough(crossed)
                .foregroundStyle(crossed ? .secondary : .primary)
        }
    }
}
