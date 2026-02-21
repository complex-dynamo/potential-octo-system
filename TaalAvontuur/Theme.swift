import SwiftUI

// MARK: - App Color Theme
struct AppTheme {
    // Primary pastel palette
    static let pastelPink = Color(red: 1.0, green: 0.71, blue: 0.76)
    static let pastelPurple = Color(red: 0.78, green: 0.58, blue: 0.90)
    static let pastelBlue = Color(red: 0.68, green: 0.85, blue: 0.95)
    static let pastelYellow = Color(red: 1.0, green: 0.93, blue: 0.55)
    static let pastelGreen = Color(red: 0.56, green: 0.90, blue: 0.68)
    static let pastelOrange = Color(red: 1.0, green: 0.78, blue: 0.50)
    static let pastelMint = Color(red: 0.70, green: 0.96, blue: 0.88)

    // Accent colors
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let chocolateBrown = Color(red: 0.55, green: 0.27, blue: 0.07)
    static let deepPurple = Color(red: 0.50, green: 0.25, blue: 0.70)

    // Background
    static let backgroundTop = Color(red: 1.0, green: 0.95, blue: 0.97)
    static let backgroundBottom = Color(red: 0.93, green: 0.90, blue: 1.0)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // World-specific gradient pairs
    static let chocolateGradient: [Color] = [
        Color(red: 0.72, green: 0.45, blue: 0.20),
        Color(red: 0.55, green: 0.27, blue: 0.07),
    ]
    static let unicornGradient: [Color] = [
        Color(red: 0.90, green: 0.70, blue: 1.0),
        Color(red: 0.78, green: 0.58, blue: 0.90),
    ]
    static let balletGradient: [Color] = [
        Color(red: 1.0, green: 0.80, blue: 0.86),
        Color(red: 1.0, green: 0.60, blue: 0.72),
    ]
    static let minionGradient: [Color] = [
        Color(red: 1.0, green: 0.93, blue: 0.55),
        Color(red: 1.0, green: 0.82, blue: 0.20),
    ]
    static let schoolGradient: [Color] = [
        Color(red: 0.68, green: 0.85, blue: 0.95),
        Color(red: 0.45, green: 0.70, blue: 0.95),
    ]
}

// MARK: - Custom Button Styles
struct WobblyButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct BigRoundButtonStyle: ButtonStyle {
    let color: Color
    let textColor: Color

    init(color: Color, textColor: Color = .white) {
        self.color = color
        self.textColor = textColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - View Modifiers
struct CardStyle: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            )
    }
}

extension View {
    func cardStyle(color: Color = .white) -> some View {
        modifier(CardStyle(color: color))
    }
}
