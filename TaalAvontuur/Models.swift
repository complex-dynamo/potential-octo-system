import SwiftUI

// MARK: - Learning Language
enum LearningLanguage: String, CaseIterable {
    case english = "Engels"
    case japanese = "Japans"

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .japanese: return "🇯🇵"
        }
    }

    var speechCode: String {
        switch self {
        case .english: return "en-US"
        case .japanese: return "ja-JP"
        }
    }
}

// MARK: - Word
struct Word: Identifiable, Equatable, Hashable {
    let id: String
    let dutch: String
    let english: String
    let japanese: String
    let romaji: String
    let emoji: String

    init(dutch: String, english: String, japanese: String, romaji: String, emoji: String) {
        self.id = "\(dutch)-\(english)"
        self.dutch = dutch
        self.english = english
        self.japanese = japanese
        self.romaji = romaji
        self.emoji = emoji
    }

    static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Returns the word in the target language
    func targetWord(for language: LearningLanguage) -> String {
        switch language {
        case .english: return english
        case .japanese: return japanese
        }
    }

    /// Returns a display-friendly version (with romaji for Japanese)
    func targetDisplay(for language: LearningLanguage) -> String {
        switch language {
        case .english: return english
        case .japanese: return "\(japanese)\n(\(romaji))"
        }
    }

    /// The raw text to speak (without romaji parenthetical)
    func speakableTarget(for language: LearningLanguage) -> String {
        switch language {
        case .english: return english
        case .japanese: return japanese
        }
    }
}

// MARK: - Game World
struct GameWorld: Identifiable {
    let id: Int
    let name: String
    let icon: String
    let color: Color
    let gradientColors: [Color]
    let subtitle: String
    let words: [Word]
}

// MARK: - Activity Type
enum ActivityType: String, CaseIterable, Identifiable {
    case learn = "Leren"
    case memory = "Memory"
    case quiz = "Quiz"
    case draw = "Tekenen"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .learn: return "📚"
        case .memory: return "🃏"
        case .quiz: return "🎯"
        case .draw: return "🎨"
        }
    }

    var dutchDescription: String {
        switch self {
        case .learn: return "Nieuwe woordjes leren"
        case .memory: return "Zoek de paren"
        case .quiz: return "Ken jij het woord?"
        case .draw: return "Teken en leer"
        }
    }
}

// MARK: - Memory Card
struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let word: Word
    let isEmoji: Bool // true = shows emoji, false = shows word
    var isFaceUp: Bool = false
    var isMatched: Bool = false

    static func == (lhs: MemoryCard, rhs: MemoryCard) -> Bool {
        lhs.id == rhs.id
    }

    /// Two cards match if they refer to the same word but one is emoji, one is text
    func matches(_ other: MemoryCard) -> Bool {
        word == other.word && isEmoji != other.isEmoji
    }
}
