import SwiftUI

// MARK: - Celebration Overlay (confetti + message)
struct CelebrationView: View {
    @Binding var isShowing: Bool
    var starsEarned: Int = 2
    var message: String = "Goed gedaan!"
    var onDismiss: () -> Void = {}

    @State private var animate = false
    @State private var showContent = false

    var body: some View {
        if isShowing {
            ZStack {
                // Dimmed background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }

                // Falling celebration emoji
                ForEach(0..<25, id: \.self) { i in
                    CelebrationPiece(index: i, animate: animate)
                }

                // Center card
                if showContent {
                    VStack(spacing: 16) {
                        Text("🎉")
                            .font(.system(size: 60))

                        Text(message)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.deepPurple)

                        // Stars earned
                        HStack(spacing: 4) {
                            ForEach(0..<starsEarned, id: \.self) { _ in
                                Text("⭐️")
                                    .font(.system(size: 36))
                            }
                        }
                        .padding(.vertical, 4)

                        Text("Je hebt \(starsEarned) sterren verdiend!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)

                        Button {
                            dismiss()
                        } label: {
                            Text("Verder!")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 160, height: 50)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.pastelPurple)
                                        .shadow(color: AppTheme.pastelPurple.opacity(0.4), radius: 6, y: 3)
                                )
                        }
                        .padding(.top, 8)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
                    )
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    animate = true
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                    showContent = true
                }
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.2)) {
            showContent = false
            isShowing = false
            animate = false
        }
        onDismiss()
    }
}

// MARK: - Individual Confetti Piece
struct CelebrationPiece: View {
    let index: Int
    let animate: Bool

    private let emojis = ["⭐️", "🎉", "✨", "🌟", "💖", "🦄", "🎊", "💫", "🩷", "🍫"]

    // Deterministic position based on index
    private var xPosition: CGFloat {
        let seed = index * 73 + 17
        return CGFloat(seed % 350) - 175
    }

    private var endY: CGFloat {
        let seed = index * 41 + 29
        return CGFloat(seed % 300) + 200
    }

    private var startY: CGFloat {
        return -CGFloat((index * 31 + 13) % 150) - 50
    }

    private var rotationAmount: Double {
        Double((index * 67 + 23) % 360)
    }

    private var animationDuration: Double {
        1.5 + Double((index * 19) % 15) / 10.0
    }

    private var delay: Double {
        Double(index) * 0.06
    }

    var body: some View {
        Text(emojis[index % emojis.count])
            .font(.system(size: CGFloat(18 + (index * 7) % 16)))
            .offset(
                x: xPosition,
                y: animate ? endY : startY
            )
            .rotationEffect(.degrees(animate ? rotationAmount : 0))
            .opacity(animate ? 0 : 1)
            .animation(
                .easeIn(duration: animationDuration).delay(delay),
                value: animate
            )
    }
}

// MARK: - Simple Star Burst (for correct answers)
struct StarBurst: View {
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    Text("⭐️")
                        .font(.system(size: 20))
                        .offset(
                            x: cos(Double(i) * .pi / 4) * 40,
                            y: sin(Double(i) * .pi / 4) * 40
                        )
                        .opacity(isShowing ? 0 : 1)
                        .scaleEffect(isShowing ? 1.5 : 0.5)
                }
            }
            .animation(.easeOut(duration: 0.6), value: isShowing)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isShowing = false
                }
            }
        }
    }
}
