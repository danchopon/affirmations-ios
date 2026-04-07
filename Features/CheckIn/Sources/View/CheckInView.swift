import SwiftUI
import SwiftData
import CoreAnalytics
import CoreAI
import CorePersistence
import DesignSystem

public struct CheckInView: View {
    @Environment(\.analytics) private var analytics
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.id) private var profiles: [UserProfile]

    @State private var viewModel: CheckInViewModel?

    public init() {}

    public var body: some View {
        Group {
            if let vm = viewModel {
                CheckInContent(vm: vm)
            } else {
                ProgressView()
                    .onAppear { setupViewModel() }
            }
        }
    }

    private func setupViewModel() {
        guard viewModel == nil else { return }
        let vm = CheckInViewModel(
            analytics: analytics,
            aiService: aiService,
            modelContext: modelContext
        )
        viewModel = vm
        vm.onAppear()
    }
}

// MARK: - Content

@MainActor
private struct CheckInContent: View {
    @Bindable var vm: CheckInViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                switch vm.currentStep {
                case .moodScore:
                    MoodScoreStep(vm: vm)
                case .emotions:
                    EmotionsStep(vm: vm)
                case .note:
                    NoteStep(vm: vm)
                case .summary:
                    SummaryStep(vm: vm)
                }
            }
            .padding()
            .navigationTitle("How are you?")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Steps

@MainActor
private struct MoodScoreStep: View {
    @Bindable var vm: CheckInViewModel

    var body: some View {
        VStack(spacing: 32) {
            Text("Rate your mood")
                .font(.appHeadline)

            Text("\(vm.selectedScore)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(vm.selectedScore.moodColor)

            Slider(value: Binding(
                get: { Double(vm.selectedScore) },
                set: { vm.selectScore(Int($0)) }
            ), in: 1...10, step: 1)
            .tint(vm.selectedScore.moodColor)

            Button("Continue") {
                vm.currentStep = .emotions
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

@MainActor
private struct EmotionsStep: View {
    @Bindable var vm: CheckInViewModel

    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        VStack(spacing: 24) {
            Text("What are you feeling?")
                .font(.appHeadline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Emotion.allCases, id: \.self) { emotion in
                    EmotionChip(
                        emotion: emotion,
                        isSelected: vm.selectedEmotions.contains(emotion),
                        action: { vm.toggleEmotion(emotion) }
                    )
                }
            }

            Button("Continue") {
                vm.proceedFromEmotions()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

@MainActor
private struct EmotionChip: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emotion.emoji)
                    .font(.title2)
                Text(emotion.displayName)
                    .font(.appCaption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.appPrimary.opacity(0.15) : Color.secondary.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

@MainActor
private struct NoteStep: View {
    @Bindable var vm: CheckInViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Anything on your mind?")
                .font(.appHeadline)

            TextField("Optional note...", text: $vm.note, axis: .vertical)
                .lineLimit(4...8)
                .textFieldStyle(.roundedBorder)

            Button("Complete Check-in") {
                vm.currentStep = .summary
            }
            .buttonStyle(.borderedProminent)

            Button("Skip") {
                vm.currentStep = .summary
            }
            .foregroundStyle(.secondary)
        }
    }
}

@MainActor
private struct SummaryStep: View {
    @Bindable var vm: CheckInViewModel
    @Query(sort: \UserProfile.id) private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 24) {
            if vm.isGeneratingAffirmation {
                ProgressView("Generating your affirmation...")
            } else if let text = vm.generatedAffirmation {
                VStack(spacing: 16) {
                    Text(text)
                        .font(.appBody)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.secondary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    if let msg = vm.errorMessage {
                        Text(msg)
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Color.clear.onAppear {
                    Task {
                        await vm.completeCheckIn(userProfile: profiles.first)
                    }
                }
            }
        }
        .sheet(isPresented: $vm.showAIConsent) {
            ConsentSheetWrapper(vm: vm, profiles: profiles)
        }
    }
}

/// Wrapper that can hand the current MoodEntry back to the consent callbacks.
/// The entry was already saved by completeCheckIn before consent was needed.
@MainActor
private struct ConsentSheetWrapper: View {
    @Bindable var vm: CheckInViewModel
    let profiles: [UserProfile]
    @Query(sort: \MoodEntry.date, order: .reverse) private var recentEntries: [MoodEntry]

    var body: some View {
        AIConsentView(
            onAccept: {
                guard let profile = profiles.first, let entry = recentEntries.first else { return }
                Task { await vm.acceptAIConsent(profile: profile, entry: entry) }
            },
            onDecline: {
                guard let entry = recentEntries.first else { return }
                Task { await vm.declineAIConsent(entry: entry) }
            }
        )
    }
}
