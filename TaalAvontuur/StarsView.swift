import SwiftUI

struct StarsView: View {
    @Binding var language: LearningLanguage
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var speech: SpeechManager
    @Environment(\.dismiss) private var dismiss

    private let worlds = WordData.allWorlds

    // Star milestones with rewards
    private let milestones: [(stars: Int, emoji: String, title: String)] = [
        (5, "🌟", "Ster Leerling"),
        (15, "🏅", "Taal Held"),
        (30, "👑", "Taal Kampioen"),
        (50, "🦄", "Eenhoorn Meester"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Big star display
                        starDisplay

                        // Milestones
                        milestonesSection

                        // Per-world progress
                        worldProgressSection

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Star Display
    private var starDisplay: some View {
        VStack(spacing: 12) {
            Text("⭐️")
                .font(.system(size: 72))

            Text("\(progress.totalStars)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.gold)

            Text("sterren verzameld!")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .shadow(color: AppTheme.gold.opacity(0.2), radius: 10, y: 4)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Milestones
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Beloningen")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.deepPurple)
                .padding(.horizontal, 24)

            VStack(spacing: 10) {
                ForEach(milestones, id: \.stars) { milestone in
                    HStack(spacing: 14) {
                        Text(milestone.emoji)
                            .font(.system(size: 32))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(
                                        progress.totalStars >= milestone.stars
                                            ? AppTheme.gold.opacity(0.2)
                                            : Color.gray.opacity(0.1)
                                    )
                            )
                            .grayscale(progress.totalStars >= milestone.stars ? 0 : 0.8)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(milestone.title)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(
                                    progress.totalStars >= milestone.stars ? .primary : .secondary
                                )

                            Text("\(milestone.stars) sterren")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if progress.totalStars >= milestone.stars {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.pastelGreen)
                        } else {
                            Text("\(milestone.stars - progress.totalStars) te gaan")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.04), radius: 3, y: 2)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - World Progress
    private var worldProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Voortgang per wereld")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.deepPurple)

                Spacer()

                Text(language.flag)
                    .font(.system(size: 20))
            }
            .padding(.horizontal, 24)

            VStack(spacing: 10) {
                ForEach(worlds) { world in
                    let completed = progress.completedActivitiesCount(
                        worldId: world.id,
                        language: language
                    )
                    let total = ActivityType.allCases.count

                    HStack(spacing: 12) {
                        Text(world.icon)
                            .font(.system(size: 28))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(world.name)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)

                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(height: 8)

                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: world.gradientColors,
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geo.size.width * CGFloat(completed) / CGFloat(total),
                                            height: 8
                                        )
                                }
                            }
                            .frame(height: 8)
                        }

                        Text("\(completed)/\(total)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(completed == total ? AppTheme.pastelGreen : .secondary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.04), radius: 3, y: 2)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
