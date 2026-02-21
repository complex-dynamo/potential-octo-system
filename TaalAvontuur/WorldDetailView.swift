import SwiftUI

struct WorldDetailView: View {
    let world: GameWorld
    @Binding var language: LearningLanguage
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var speech: SpeechManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedActivity: ActivityType?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [world.gradientColors[0].opacity(0.3), AppTheme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // World header
                    VStack(spacing: 8) {
                        Text(world.icon)
                            .font(.system(size: 72))

                        Text(world.name)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.deepPurple)

                        Text(world.subtitle)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    // Language indicator
                    HStack(spacing: 6) {
                        Text(language.flag)
                            .font(.system(size: 20))
                        Text("Je leert: \(language.rawValue)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.8))
                    )

                    // Activity buttons
                    VStack(spacing: 14) {
                        ForEach(ActivityType.allCases) { activity in
                            ActivityButton(
                                activity: activity,
                                world: world,
                                isCompleted: progress.isCompleted(
                                    worldId: world.id,
                                    activity: activity,
                                    language: language
                                )
                            ) {
                                selectedActivity = activity
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Word preview
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Woordjes in deze wereld:")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(world.words) { word in
                                    VStack(spacing: 4) {
                                        Text(word.emoji)
                                            .font(.system(size: 32))
                                        Text(word.dutch)
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: 64, height: 72)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(.white.opacity(0.8))
                                    )
                                    .onTapGesture {
                                        speech.speakDutch(word.dutch)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                StarCounter(count: progress.totalStars)
            }
        }
        .navigationDestination(item: $selectedActivity) { activity in
            activityView(for: activity)
        }
    }

    @ViewBuilder
    private func activityView(for activity: ActivityType) -> some View {
        switch activity {
        case .learn:
            FlashCardView(world: world, language: $language)
        case .memory:
            MemoryGameView(world: world, language: $language)
        case .quiz:
            QuizGameView(world: world, language: $language)
        case .draw:
            DrawingView(world: world, language: $language)
        }
    }
}

// MARK: - Activity Button
struct ActivityButton: View {
    let activity: ActivityType
    let world: GameWorld
    let isCompleted: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Activity icon
                Text(activity.icon)
                    .font(.system(size: 36))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(world.color.opacity(0.15))
                    )

                // Activity info
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.rawValue)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(activity.dutchDescription)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Completion indicator
                if isCompleted {
                    Text("⭐️")
                        .font(.system(size: 24))
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(world.color)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(WobblyButtonStyle(color: world.color))
    }
}

// MARK: - Make ActivityType work with navigationDestination
extension ActivityType: Hashable {}
