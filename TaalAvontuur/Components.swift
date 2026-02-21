import SwiftUI

// MARK: - Star Counter (shown in top bar)
struct StarCounter: View {
    let count: Int
    @State private var bounce = false

    var body: some View {
        HStack(spacing: 4) {
            Text("⭐️")
                .font(.system(size: 22))
                .scaleEffect(bounce ? 1.3 : 1.0)
            Text("\(count)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.gold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.white.opacity(0.9))
                .shadow(color: AppTheme.gold.opacity(0.3), radius: 4, y: 2)
        )
        .onChange(of: count) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                bounce = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                bounce = false
            }
        }
    }
}

// MARK: - Speech Bubble (for Sterre the unicorn guide)
struct SpeechBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            )
            .overlay(
                // Little triangle pointing down
                Triangle()
                    .fill(.white)
                    .frame(width: 20, height: 12)
                    .offset(y: 6),
                alignment: .bottom
            )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Floating Emoji Background
struct FloatingEmoji: View {
    let emoji: String
    let size: CGFloat
    @State private var yOffset: CGFloat = 0
    @State private var rotation: Double = 0

    let baseX: CGFloat
    let baseY: CGFloat
    let duration: Double

    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .offset(x: baseX, y: baseY + yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(0.4)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    yOffset = -20
                    rotation = Double.random(in: -15...15)
                }
            }
    }
}

// MARK: - Animated Unicorn Guide (Sterre)
struct SterreGuide: View {
    let message: String
    @State private var bounceY: CGFloat = 0
    @State private var showMessage = false

    var body: some View {
        VStack(spacing: 4) {
            if showMessage {
                SpeechBubble(text: message)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.horizontal, 32)
            }

            Text("🦄")
                .font(.system(size: 64))
                .offset(y: bounceY)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                    ) {
                        bounceY = -8
                    }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
                        showMessage = true
                    }
                }
        }
    }
}

// MARK: - Big Emoji Circle (for cards and buttons)
struct EmojiCircle: View {
    let emoji: String
    let size: CGFloat
    let backgroundColor: Color

    init(emoji: String, size: CGFloat = 80, backgroundColor: Color = .white) {
        self.emoji = emoji
        self.size = size
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.55))
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            )
    }
}

// MARK: - Progress Dots
struct ProgressDots: View {
    let total: Int
    let current: Int
    let activeColor: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index <= current ? activeColor : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
                    .scaleEffect(index == current ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: current)
            }
        }
    }
}

// MARK: - Language Toggle
struct LanguageToggle: View {
    @Binding var language: LearningLanguage
    @EnvironmentObject var speech: SpeechManager

    var body: some View {
        HStack(spacing: 0) {
            ForEach(LearningLanguage.allCases, id: \.self) { lang in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        language = lang
                    }
                    speech.speakDutch("Nu leren we \(lang.rawValue)")
                } label: {
                    HStack(spacing: 6) {
                        Text(lang.flag)
                            .font(.system(size: 22))
                        Text(lang.rawValue)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(language == lang ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(language == lang ? AppTheme.deepPurple : Color.clear)
                    )
                }
            }
        }
        .background(
            Capsule()
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
}

// MARK: - Speaker Button
struct SpeakerButton: View {
    var size: CGFloat = 44
    let action: () -> Void

    @State private var isAnimating = false

    var body: some View {
        Button(action: {
            isAnimating = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isAnimating = false
            }
        }) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: size * 0.45))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(AppTheme.pastelPurple)
                        .shadow(color: AppTheme.pastelPurple.opacity(0.4), radius: 4, y: 2)
                )
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAnimating)
        }
    }
}

// MARK: - Back Button
struct BackButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                Text("Terug")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundColor(AppTheme.deepPurple)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
            )
        }
    }
}
