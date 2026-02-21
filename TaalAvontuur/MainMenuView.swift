import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var speech: SpeechManager
    @State private var selectedLanguage: LearningLanguage = .english
    @State private var showWorlds = false
    @State private var selectedWorld: GameWorld?
    @State private var showStars = false

    private let worlds = WordData.allWorlds

    // Decorative floating emoji for the background
    private let floatingItems: [(emoji: String, x: CGFloat, y: CGFloat, size: CGFloat, duration: Double)] = [
        ("🦄", -140, -280, 28, 3.0),
        ("⭐️", 130, -240, 22, 2.5),
        ("🍫", -100, -180, 24, 3.5),
        ("🩰", 150, -100, 26, 2.8),
        ("🌈", -150, 80, 28, 3.2),
        ("🍌", 120, 160, 24, 2.6),
        ("✨", -60, 240, 20, 3.4),
        ("💖", 80, 300, 22, 2.9),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                // Floating decorative emoji
                ForEach(Array(floatingItems.enumerated()), id: \.offset) { index, item in
                    FloatingEmoji(
                        emoji: item.emoji,
                        size: item.size,
                        baseX: item.x,
                        baseY: item.y,
                        duration: item.duration
                    )
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Top bar with stars
                        HStack {
                            Spacer()
                            Button {
                                showStars = true
                            } label: {
                                StarCounter(count: progress.totalStars)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // Sterre the unicorn guide
                        SterreGuide(message: "Hallo! Welkom bij TaalAvontuur!\nKies een wereld om te beginnen!")
                            .padding(.top, 4)

                        // Language toggle
                        LanguageToggle(language: $selectedLanguage)
                            .padding(.top, 4)

                        // Title
                        Text("Kies een wereld")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.deepPurple)
                            .padding(.top, 8)

                        // World buttons
                        VStack(spacing: 14) {
                            ForEach(worlds) { world in
                                WorldButton(
                                    world: world,
                                    language: selectedLanguage,
                                    progressFraction: progress.worldProgress(
                                        worldId: world.id,
                                        language: selectedLanguage
                                    )
                                )
                                .onTapGesture {
                                    selectedWorld = world
                                    speech.speakDutch(world.name)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationDestination(item: $selectedWorld) { world in
                WorldDetailView(
                    world: world,
                    language: $selectedLanguage
                )
            }
            .sheet(isPresented: $showStars) {
                StarsView(language: $selectedLanguage)
            }
        }
    }
}

// MARK: - World Button
struct WorldButton: View {
    let world: GameWorld
    let language: LearningLanguage
    let progressFraction: Double

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 16) {
            // World icon
            Text(world.icon)
                .font(.system(size: 44))
                .frame(width: 64, height: 64)
                .background(
                    Circle()
                        .fill(.white.opacity(0.5))
                )

            // World info
            VStack(alignment: .leading, spacing: 4) {
                Text(world.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(world.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.3))
                            .frame(height: 6)

                        Capsule()
                            .fill(.white)
                            .frame(width: geo.size.width * progressFraction, height: 6)
                            .animation(.spring(response: 0.4), value: progressFraction)
                    }
                }
                .frame(height: 6)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: world.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: world.color.opacity(0.35), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Make GameWorld work with navigationDestination
extension GameWorld: Hashable {
    static func == (lhs: GameWorld, rhs: GameWorld) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
