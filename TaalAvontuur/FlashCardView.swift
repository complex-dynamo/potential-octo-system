import SwiftUI

struct FlashCardView: View {
    let world: GameWorld
    @Binding var language: LearningLanguage
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var speech: SpeechManager
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showCelebration = false
    @State private var dragOffset: CGFloat = 0

    private var words: [Word] { world.words }
    private var currentWord: Word { words[currentIndex] }
    private var isLastCard: Bool { currentIndex >= words.count - 1 }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [world.gradientColors[0].opacity(0.2), AppTheme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                // Instruction
                SpeechBubble(text: isFlipped
                    ? "Tik op 🔊 om het woord te horen!"
                    : "Tik op de kaart om het woord te zien!"
                )
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()

                // Flash card
                ZStack {
                    // Back of card (target language)
                    cardBack
                        .rotation3DEffect(
                            .degrees(isFlipped ? 0 : -180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .opacity(isFlipped ? 1 : 0)

                    // Front of card (Dutch + emoji)
                    cardFront
                        .rotation3DEffect(
                            .degrees(isFlipped ? 180 : 0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .opacity(isFlipped ? 0 : 1)
                }
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width * 0.6
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 60
                            if value.translation.width < -threshold && !isLastCard {
                                goToNext()
                            } else if value.translation.width > threshold && currentIndex > 0 {
                                goToPrevious()
                            }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dragOffset = 0
                            }
                        }
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isFlipped.toggle()
                    }
                    if isFlipped {
                        speech.speakTarget(currentWord.speakableTarget(for: language), language: language)
                    } else {
                        speech.speakDutch(currentWord.dutch)
                    }
                }

                Spacer()

                // Progress dots
                ProgressDots(
                    total: words.count,
                    current: currentIndex,
                    activeColor: world.color
                )

                // Navigation buttons
                HStack(spacing: 40) {
                    // Previous
                    Button {
                        goToPrevious()
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(currentIndex > 0 ? world.color : Color.gray.opacity(0.3))
                    }
                    .disabled(currentIndex <= 0)

                    // Speaker
                    SpeakerButton(size: 56) {
                        if isFlipped {
                            speech.speakTarget(currentWord.speakableTarget(for: language), language: language)
                        } else {
                            speech.speakDutch(currentWord.dutch)
                        }
                    }

                    // Next / Complete
                    Button {
                        if isLastCard {
                            completeActivity()
                        } else {
                            goToNext()
                        }
                    } label: {
                        if isLastCard {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.pastelGreen)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(world.color)
                        }
                    }
                }
                .padding(.bottom, 24)
            }

            // Celebration overlay
            CelebrationView(
                isShowing: $showCelebration,
                starsEarned: progress.starsForActivity(.learn),
                message: "Alle woordjes geleerd!"
            ) {
                dismiss()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView {
                    speech.stop()
                    dismiss()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("\(world.icon) \(world.name)")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
        }
        .onAppear {
            speech.speakDutch("Tik op de kaart!")
        }
    }

    // MARK: - Card Front (Dutch + emoji)
    private var cardFront: some View {
        VStack(spacing: 16) {
            Text(currentWord.emoji)
                .font(.system(size: 80))

            Text(currentWord.dutch)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("🇳🇱 Nederlands")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(width: 280, height: 360)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white)
                .shadow(color: world.color.opacity(0.3), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(world.color.opacity(0.3), lineWidth: 3)
        )
    }

    // MARK: - Card Back (target language)
    private var cardBack: some View {
        VStack(spacing: 16) {
            Text(currentWord.emoji)
                .font(.system(size: 80))

            Text(currentWord.targetDisplay(for: language))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.deepPurple)
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Text(language.flag)
                Text(language.rawValue)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 280, height: 360)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [.white, world.gradientColors[0].opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: world.color.opacity(0.3), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(world.color.opacity(0.5), lineWidth: 3)
        )
    }

    // MARK: - Navigation
    private func goToNext() {
        guard !isLastCard else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isFlipped = false
            currentIndex += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            speech.speakDutch(words[currentIndex].dutch)
        }
    }

    private func goToPrevious() {
        guard currentIndex > 0 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isFlipped = false
            currentIndex -= 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            speech.speakDutch(words[currentIndex].dutch)
        }
    }

    private func completeActivity() {
        progress.markCompleted(worldId: world.id, activity: .learn, language: language)
        showCelebration = true
    }
}
