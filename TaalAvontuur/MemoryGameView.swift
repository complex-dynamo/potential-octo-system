import SwiftUI

struct MemoryGameView: View {
    let world: GameWorld
    @Binding var language: LearningLanguage
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var speech: SpeechManager
    @Environment(\.dismiss) private var dismiss

    @State private var cards: [MemoryCard] = []
    @State private var firstFlipped: MemoryCard?
    @State private var isProcessing = false
    @State private var matchedCount = 0
    @State private var moves = 0
    @State private var showCelebration = false
    @State private var correctPairFlash = false

    // Use 6 words for the memory game (12 cards = 3x4 grid)
    private let pairCount = 6

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [world.gradientColors[0].opacity(0.2), AppTheme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                // Instruction
                SpeechBubble(text: "Zoek de paren! Tik op twee kaarten.")
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                // Stats
                HStack(spacing: 20) {
                    Label("\(moves)", systemImage: "hand.tap")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)

                    Label("\(matchedCount)/\(pairCount)", systemImage: "checkmark.circle")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.pastelGreen)
                }
                .padding(.vertical, 4)

                // Card grid (3 columns x 4 rows)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                    ],
                    spacing: 10
                ) {
                    ForEach(cards) { card in
                        MemoryCardView(
                            card: card,
                            worldColor: world.color,
                            language: language
                        )
                        .onTapGesture {
                            cardTapped(card)
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }

            // Celebration
            CelebrationView(
                isShowing: $showCelebration,
                starsEarned: progress.starsForActivity(.memory),
                message: "Alle paren gevonden!"
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
                Text("🃏 Memory")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
        }
        .onAppear {
            setupGame()
            speech.speakDutch("Zoek de paren!")
        }
    }

    // MARK: - Game Setup
    private func setupGame() {
        let selectedWords = Array(world.words.shuffled().prefix(pairCount))
        var newCards: [MemoryCard] = []

        for word in selectedWords {
            // One card with emoji
            newCards.append(MemoryCard(word: word, isEmoji: true))
            // One card with the target language word
            newCards.append(MemoryCard(word: word, isEmoji: false))
        }

        cards = newCards.shuffled()
        firstFlipped = nil
        matchedCount = 0
        moves = 0
        isProcessing = false
    }

    // MARK: - Card Tap Logic
    private func cardTapped(_ card: MemoryCard) {
        guard !isProcessing else { return }
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard !cards[index].isFaceUp && !cards[index].isMatched else { return }

        // Flip the card
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cards[index].isFaceUp = true
        }

        // Speak the word
        if card.isEmoji {
            speech.speakDutch(card.word.dutch)
        } else {
            speech.speakTarget(card.word.speakableTarget(for: language), language: language)
        }

        if let first = firstFlipped {
            // Second card flipped
            moves += 1
            isProcessing = true

            if first.matches(cards[index]) {
                // Match found!
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        if let firstIdx = cards.firstIndex(where: { $0.id == first.id }) {
                            cards[firstIdx].isMatched = true
                        }
                        cards[index].isMatched = true
                        matchedCount += 1
                    }
                    firstFlipped = nil
                    isProcessing = false

                    // Check for game complete
                    if matchedCount >= pairCount {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            progress.markCompleted(worldId: world.id, activity: .memory, language: language)
                            showCelebration = true
                        }
                    }
                }
            } else {
                // No match — flip both back
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        if let firstIdx = cards.firstIndex(where: { $0.id == first.id }) {
                            cards[firstIdx].isFaceUp = false
                        }
                        cards[index].isFaceUp = false
                    }
                    firstFlipped = nil
                    isProcessing = false
                }
            }
        } else {
            // First card flipped
            firstFlipped = cards[index]
        }
    }
}

// MARK: - Individual Memory Card View
struct MemoryCardView: View {
    let card: MemoryCard
    let worldColor: Color
    let language: LearningLanguage

    var body: some View {
        ZStack {
            if card.isMatched {
                // Matched card — show with green border
                cardContent
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(AppTheme.pastelGreen, lineWidth: 3)
                    )
                    .opacity(0.7)
            } else if card.isFaceUp {
                // Face up
                cardContent
            } else {
                // Face down
                cardBack
            }
        }
        .frame(height: 100)
    }

    private var cardContent: some View {
        VStack(spacing: 4) {
            if card.isEmoji {
                Text(card.word.emoji)
                    .font(.system(size: 36))
                Text(card.word.dutch)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            } else {
                Text(card.word.emoji)
                    .font(.system(size: 20))
                Text(card.word.targetDisplay(for: language))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.deepPurple)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
                .shadow(color: worldColor.opacity(0.2), radius: 4, y: 2)
        )
    }

    private var cardBack: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [worldColor, worldColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: worldColor.opacity(0.3), radius: 4, y: 2)

            Text("?")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
