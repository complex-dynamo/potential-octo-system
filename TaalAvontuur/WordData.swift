import SwiftUI

// MARK: - All Word Data for the Five Worlds
struct WordData {

    // MARK: 🍫 De Chocoladefabriek — Food & sweets
    static let chocoladeWoorden: [Word] = [
        Word(dutch: "Chocolade", english: "Chocolate", japanese: "チョコレート", romaji: "chokorēto", emoji: "🍫"),
        Word(dutch: "Snoep", english: "Candy", japanese: "キャンディー", romaji: "kyandī", emoji: "🍬"),
        Word(dutch: "Taart", english: "Cake", japanese: "ケーキ", romaji: "kēki", emoji: "🎂"),
        Word(dutch: "Koekje", english: "Cookie", japanese: "クッキー", romaji: "kukkī", emoji: "🍪"),
        Word(dutch: "IJsje", english: "Ice cream", japanese: "アイス", romaji: "aisu", emoji: "🍦"),
        Word(dutch: "Appel", english: "Apple", japanese: "りんご", romaji: "ringo", emoji: "🍎"),
        Word(dutch: "Banaan", english: "Banana", japanese: "バナナ", romaji: "banana", emoji: "🍌"),
        Word(dutch: "Aardbei", english: "Strawberry", japanese: "いちご", romaji: "ichigo", emoji: "🍓"),
    ]

    // MARK: 🦄 Eenhoorn Vallei — Colors & magical things
    static let eenhoornWoorden: [Word] = [
        Word(dutch: "Rood", english: "Red", japanese: "あか", romaji: "aka", emoji: "🔴"),
        Word(dutch: "Blauw", english: "Blue", japanese: "あお", romaji: "ao", emoji: "🔵"),
        Word(dutch: "Geel", english: "Yellow", japanese: "きいろ", romaji: "kiiro", emoji: "🟡"),
        Word(dutch: "Roze", english: "Pink", japanese: "ピンク", romaji: "pinku", emoji: "🩷"),
        Word(dutch: "Paars", english: "Purple", japanese: "むらさき", romaji: "murasaki", emoji: "🟣"),
        Word(dutch: "Groen", english: "Green", japanese: "みどり", romaji: "midori", emoji: "🟢"),
        Word(dutch: "Regenboog", english: "Rainbow", japanese: "にじ", romaji: "niji", emoji: "🌈"),
        Word(dutch: "Ster", english: "Star", japanese: "ほし", romaji: "hoshi", emoji: "⭐️"),
    ]

    // MARK: 🩰 De Balletstudio — Body parts & movement
    static let balletWoorden: [Word] = [
        Word(dutch: "Hand", english: "Hand", japanese: "て", romaji: "te", emoji: "🤚"),
        Word(dutch: "Voet", english: "Foot", japanese: "あし", romaji: "ashi", emoji: "🦶"),
        Word(dutch: "Hoofd", english: "Head", japanese: "あたま", romaji: "atama", emoji: "🗣️"),
        Word(dutch: "Dansen", english: "Dance", japanese: "ダンス", romaji: "dansu", emoji: "💃"),
        Word(dutch: "Springen", english: "Jump", japanese: "ジャンプ", romaji: "janpu", emoji: "🤸"),
        Word(dutch: "Draaien", english: "Turn", japanese: "まわる", romaji: "mawaru", emoji: "🔄"),
        Word(dutch: "Muziek", english: "Music", japanese: "おんがく", romaji: "ongaku", emoji: "🎵"),
        Word(dutch: "Jurk", english: "Dress", japanese: "ドレス", romaji: "doresu", emoji: "👗"),
    ]

    // MARK: 🍌 Minion Avontuur — Greetings & expressions
    static let minionWoorden: [Word] = [
        Word(dutch: "Hallo", english: "Hello", japanese: "こんにちは", romaji: "konnichiwa", emoji: "👋"),
        Word(dutch: "Doei", english: "Goodbye", japanese: "さようなら", romaji: "sayōnara", emoji: "🫡"),
        Word(dutch: "Dankjewel", english: "Thank you", japanese: "ありがとう", romaji: "arigatō", emoji: "🙏"),
        Word(dutch: "Ja", english: "Yes", japanese: "はい", romaji: "hai", emoji: "✅"),
        Word(dutch: "Nee", english: "No", japanese: "いいえ", romaji: "iie", emoji: "❌"),
        Word(dutch: "Alsjeblieft", english: "Please", japanese: "おねがい", romaji: "onegai", emoji: "🙂"),
        Word(dutch: "Sorry", english: "Sorry", japanese: "ごめんね", romaji: "gomen ne", emoji: "😢"),
        Word(dutch: "Vriend", english: "Friend", japanese: "ともだち", romaji: "tomodachi", emoji: "🤝"),
    ]

    // MARK: 🏫 De Speelschool — Numbers & school items
    static let schoolWoorden: [Word] = [
        Word(dutch: "Eén", english: "One", japanese: "いち", romaji: "ichi", emoji: "1️⃣"),
        Word(dutch: "Twee", english: "Two", japanese: "に", romaji: "ni", emoji: "2️⃣"),
        Word(dutch: "Drie", english: "Three", japanese: "さん", romaji: "san", emoji: "3️⃣"),
        Word(dutch: "Vier", english: "Four", japanese: "よん", romaji: "yon", emoji: "4️⃣"),
        Word(dutch: "Vijf", english: "Five", japanese: "ご", romaji: "go", emoji: "5️⃣"),
        Word(dutch: "Boek", english: "Book", japanese: "ほん", romaji: "hon", emoji: "📖"),
        Word(dutch: "Pen", english: "Pen", japanese: "ペン", romaji: "pen", emoji: "🖊️"),
        Word(dutch: "School", english: "School", japanese: "がっこう", romaji: "gakkō", emoji: "🏫"),
    ]

    // MARK: - All Worlds
    static let allWorlds: [GameWorld] = [
        GameWorld(
            id: 0,
            name: "De Chocoladefabriek",
            icon: "🍫",
            color: AppTheme.chocolateBrown,
            gradientColors: AppTheme.chocolateGradient,
            subtitle: "Lekkers & eten",
            words: chocoladeWoorden
        ),
        GameWorld(
            id: 1,
            name: "Eenhoorn Vallei",
            icon: "🦄",
            color: AppTheme.pastelPurple,
            gradientColors: AppTheme.unicornGradient,
            subtitle: "Kleuren & magie",
            words: eenhoornWoorden
        ),
        GameWorld(
            id: 2,
            name: "De Balletstudio",
            icon: "🩰",
            color: AppTheme.pastelPink,
            gradientColors: AppTheme.balletGradient,
            subtitle: "Lichaam & bewegen",
            words: balletWoorden
        ),
        GameWorld(
            id: 3,
            name: "Minion Avontuur",
            icon: "🍌",
            color: AppTheme.pastelYellow,
            gradientColors: AppTheme.minionGradient,
            subtitle: "Begroetingen & uitdrukkingen",
            words: minionWoorden
        ),
        GameWorld(
            id: 4,
            name: "De Speelschool",
            icon: "🏫",
            color: AppTheme.pastelBlue,
            gradientColors: AppTheme.schoolGradient,
            subtitle: "Cijfers & school",
            words: schoolWoorden
        ),
    ]
}
