import AVFoundation
import SwiftUI

/// Manages text-to-speech for Dutch instructions and English/Japanese word pronunciation
class SpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    /// Speak text in the given language code
    func speak(_ text: String, languageCode: String, rate: Float = 0.38, pitch: Float = 1.15) {
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.preUtteranceDelay = 0.1

        synthesizer.speak(utterance)
    }

    /// Speak a Dutch instruction (for the UI / guide)
    func speakDutch(_ text: String) {
        speak(text, languageCode: "nl-NL", rate: 0.42, pitch: 1.1)
    }

    /// Speak a word in the target learning language
    func speakTarget(_ text: String, language: LearningLanguage) {
        speak(text, languageCode: language.speechCode, rate: 0.35, pitch: 1.15)
    }

    /// Speak the Dutch word first, then the target word after a pause
    func speakBoth(dutch: String, target: String, language: LearningLanguage) {
        speakDutch(dutch)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.speakTarget(target, language: language)
        }
    }

    /// Stop all speech
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
