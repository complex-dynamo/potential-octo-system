import SwiftUI

struct QuizGameView: View {
    let world: GameWorld
    @Binding var language: LearningLanguage
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var speech: SpeechManager
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var showCelebration = false
    @State private var shakeWrong = false

    private let questionCount = 8

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [world.gradientColors[0].opacity(0.2), AppTheme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if questions.isEmpty {
                ProgressView()
                    .onAppear { setupQuiz() }
            } else if currentIndex < questions.count {
                questionView
            }

            // Celebration
            CelebrationView(
                isShowing: $showCelebration,
                starsEarned: progress.starsForActivity(.quiz),
                message: "Super gedaan! \(score)/\(questions.count) goed!"
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
                Text("🎯 Quiz")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
        }
    }

    // MARK: - Question View
    private var questionView: some View {
        let question = questions[currentIndex]

        return VStack(spacing: 16) {
            // Progress
            HStack {
                ProgressDots(
                    total: questions.count,
                    current: currentIndex,
                    activeColor: world.color
                )

                Spacer()

                // Score
                HStack(spacing: 4) {
                    Text("⭐️")
                        .font(.system(size: 18))
                    Text("\(score)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.gold)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            // Instruction
            SpeechBubble(text: "Welk woord hoort bij het plaatje?")
                .padding(.horizontal, 24)

            Spacer()

            // Question emoji + Dutch word
            VStack(spacing: 12) {
                Text(question.correctWord.emoji)
                    .font(.system(size: 90))

                Text(question.correctWord.dutch)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                // Speaker button
                SpeakerButton(size: 44) {
                    speech.speakBoth(
                        dutch: question.correctWord.dutch,
                        target: question.correctWord.speakableTarget(for: language),
                        language: language
                    )
                }
            }
            .padding(.vertical, 8)

            Spacer()

            // Answer options
            VStack(spacing: 12) {
                ForEach(0..<question.options.count, id: \.self) { optionIndex in
                    answerButton(
                        option: question.options[optionIndex],
                        optionIndex: optionIndex,
                        isCorrect: question.options[optionIndex] == question.correctWord
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .onAppear {
            speech.speakDutch(question.correctWord.dutch)
        }
    }

    // MARK: - Answer Button
    private func answerButton(option: Word, optionIndex: Int, isCorrect: Bool) -> some View {
        Button {
            guard selectedAnswer == nil else { return }
            answerSelected(optionIndex: optionIndex, isCorrect: isCorrect, option: option)
        } label: {
            HStack {
                Text(option.targetDisplay(for: language))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(buttonTextColor(optionIndex: optionIndex, isCorrect: isCorrect))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Spacer()

                if showResult && selectedAnswer == optionIndex {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(buttonBackground(optionIndex: optionIndex, isCorrect: isCorrect))
                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        buttonBorder(optionIndex: optionIndex, isCorrect: isCorrect),
                        lineWidth: selectedAnswer == optionIndex ? 3 : 0
                    )
            )
            .offset(x: shakeWrong && selectedAnswer == optionIndex && !isCorrect ? -8 : 0)
        }
        .disabled(selectedAnswer != nil)
    }

    // MARK: - Answer Colors
    private func buttonTextColor(optionIndex: Int, isCorrect: Bool) -> Color {
        guard showResult else { return .primary }
        if selectedAnswer == optionIndex {
            return isCorrect ? .green : .red
        }
        if isCorrect { return .green }
        return .primary.opacity(0.4)
    }

    private func buttonBackground(optionIndex: Int, isCorrect: Bool) -> Color {
        guard showResult else { return .white }
        if isCorrect { return Color.green.opacity(0.1) }
        if selectedAnswer == optionIndex { return Color.red.opacity(0.1) }
        return .white.opacity(0.5)
    }

    private func buttonBorder(optionIndex: Int, isCorrect: Bool) -> Color {
        guard showResult else { return .clear }
        if isCorrect { return .green }
        if selectedAnswer == optionIndex { return .red }
        return .clear
    }

    // MARK: - Game Logic
    private func setupQuiz() {
        var quizQuestions: [QuizQuestion] = []

        let shuffledWords = world.words.shuffled()
        let count = min(questionCount, shuffledWords.count)

        for i in 0..<count {
            let correct = shuffledWords[i]

            // Pick 2 wrong answers from other words
            let wrongOptions = world.words.filter { $0 != correct }.shuffled()
            let wrongPicks = Array(wrongOptions.prefix(2))

            // Combine and shuffle options
            var options = [correct] + wrongPicks
            options.shuffle()

            quizQuestions.append(QuizQuestion(correctWord: correct, options: options))
        }

        questions = quizQuestions
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
    }

    private func answerSelected(optionIndex: Int, isCorrect: Bool, option: Word) {
        selectedAnswer = optionIndex
        showResult = true

        if isCorrect {
            score += 1
            speech.speakTarget(option.speakableTarget(for: language), language: language)
        } else {
            // Shake animation for wrong answer
            withAnimation(.default.repeatCount(3, autoreverses: true).speed(6)) {
                shakeWrong = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                shakeWrong = false
            }
        }

        // Auto-advance after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentIndex < questions.count - 1 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    currentIndex += 1
                    selectedAnswer = nil
                    showResult = false
                }
            } else {
                // Quiz complete
                progress.markCompleted(worldId: world.id, activity: .quiz, language: language)
                showCelebration = true
            }
        }
    }
}

// MARK: - Quiz Question Model
struct QuizQuestion {
    let correctWord: Word
    let options: [Word] // 3 options including the correct one
}
