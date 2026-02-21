import SwiftUI

struct DrawingView: View {
    let world: GameWorld
    @Binding var language: LearningLanguage
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var speech: SpeechManager
    @Environment(\.dismiss) private var dismiss

    @State private var lines: [DrawingLine] = []
    @State private var currentLine: DrawingLine?
    @State private var selectedColor: Color = .black
    @State private var lineWidth: CGFloat = 4
    @State private var currentPromptIndex = 0
    @State private var showCelebration = false

    private let colors: [Color] = [
        .black,
        .red,
        Color(red: 1.0, green: 0.4, blue: 0.7), // Pink
        .purple,
        .blue,
        .green,
        .orange,
        Color(red: 0.55, green: 0.27, blue: 0.07), // Brown
    ]

    private let lineWidths: [CGFloat] = [2, 4, 8]

    private var prompts: [Word] { world.words }
    private var currentPrompt: Word { prompts[currentPromptIndex % prompts.count] }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [world.gradientColors[0].opacity(0.15), AppTheme.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                // Drawing prompt
                drawingPrompt

                // Canvas
                drawingCanvas
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(world.color.opacity(0.3), lineWidth: 2)
                    )
                    .padding(.horizontal, 12)

                // Tools
                toolBar

                // Action buttons
                actionButtons
            }

            // Celebration
            CelebrationView(
                isShowing: $showCelebration,
                starsEarned: progress.starsForActivity(.draw),
                message: "Mooie tekening!"
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
                Text("🎨 Tekenen")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
        }
        .onAppear {
            speech.speakDutch("Teken \(currentPrompt.dutch)!")
        }
    }

    // MARK: - Drawing Prompt
    private var drawingPrompt: some View {
        HStack(spacing: 12) {
            Text(currentPrompt.emoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 2) {
                Text("Teken: \(currentPrompt.dutch)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(currentPrompt.targetDisplay(for: language))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.deepPurple)
                    .lineLimit(1)
            }

            Spacer()

            SpeakerButton(size: 40) {
                speech.speakBoth(
                    dutch: currentPrompt.dutch,
                    target: currentPrompt.speakableTarget(for: language),
                    language: language
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
        .padding(.horizontal, 12)
        .padding(.top, 4)
    }

    // MARK: - Drawing Canvas
    private var drawingCanvas: some View {
        GeometryReader { geometry in
            ZStack {
                // White background
                Color.white

                // Existing lines
                ForEach(lines) { line in
                    Path { path in
                        guard line.points.count > 1 else { return }
                        path.move(to: line.points[0])
                        for point in line.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(line.color, style: StrokeStyle(
                        lineWidth: line.width,
                        lineCap: .round,
                        lineJoin: .round
                    ))
                }

                // Current line being drawn
                if let current = currentLine {
                    Path { path in
                        guard current.points.count > 1 else { return }
                        path.move(to: current.points[0])
                        for point in current.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(current.color, style: StrokeStyle(
                        lineWidth: current.width,
                        lineCap: .round,
                        lineJoin: .round
                    ))
                }

                // Faint prompt emoji in center as guide
                if lines.isEmpty && currentLine == nil {
                    Text(currentPrompt.emoji)
                        .font(.system(size: 100))
                        .opacity(0.15)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let point = value.location
                        // Clamp to canvas bounds
                        let clampedPoint = CGPoint(
                            x: min(max(point.x, 0), geometry.size.width),
                            y: min(max(point.y, 0), geometry.size.height)
                        )

                        if currentLine == nil {
                            currentLine = DrawingLine(
                                color: selectedColor,
                                width: lineWidth,
                                points: [clampedPoint]
                            )
                        } else {
                            currentLine?.points.append(clampedPoint)
                        }
                    }
                    .onEnded { _ in
                        if let line = currentLine {
                            lines.append(line)
                        }
                        currentLine = nil
                    }
            )
        }
    }

    // MARK: - Tool Bar (colors + width)
    private var toolBar: some View {
        VStack(spacing: 8) {
            // Color palette
            HStack(spacing: 8) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .strokeBorder(.white, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .scaleEffect(selectedColor == color ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedColor == color)
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }

            // Line width
            HStack(spacing: 12) {
                ForEach(lineWidths, id: \.self) { width in
                    Circle()
                        .fill(selectedColor)
                        .frame(width: width * 3 + 8, height: width * 3 + 8)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    lineWidth == width ? AppTheme.deepPurple : Color.clear,
                                    lineWidth: 2
                                )
                                .padding(-3)
                        )
                        .onTapGesture {
                            lineWidth = width
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.9))
        )
        .padding(.horizontal, 12)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Undo
            Button {
                if !lines.isEmpty {
                    lines.removeLast()
                }
            } label: {
                Label("Stap terug", systemImage: "arrow.uturn.backward")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
                    )
            }

            // Clear
            Button {
                lines.removeAll()
            } label: {
                Label("Wissen", systemImage: "trash")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
                    )
            }

            Spacer()

            // Next prompt / Done
            if currentPromptIndex < prompts.count - 1 {
                Button {
                    nextPrompt()
                } label: {
                    Label("Volgende", systemImage: "arrow.right")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(world.color)
                                .shadow(color: world.color.opacity(0.3), radius: 3, y: 2)
                        )
                }
            } else {
                Button {
                    completeDrawing()
                } label: {
                    Label("Klaar!", systemImage: "checkmark")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppTheme.pastelGreen)
                                .shadow(color: AppTheme.pastelGreen.opacity(0.3), radius: 3, y: 2)
                        )
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    // MARK: - Actions
    private func nextPrompt() {
        lines.removeAll()
        currentLine = nil
        withAnimation {
            currentPromptIndex += 1
        }
        speech.speakDutch("Teken \(currentPrompt.dutch)!")
    }

    private func completeDrawing() {
        progress.markCompleted(worldId: world.id, activity: .draw, language: language)
        showCelebration = true
    }
}

// MARK: - Drawing Line Model
struct DrawingLine: Identifiable {
    let id = UUID()
    let color: Color
    let width: CGFloat
    var points: [CGPoint]
}
