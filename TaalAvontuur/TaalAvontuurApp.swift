import SwiftUI

@main
struct TaalAvontuurApp: App {
    @StateObject private var progressManager = ProgressManager()
    @StateObject private var speechManager = SpeechManager()

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environmentObject(progressManager)
                .environmentObject(speechManager)
                .preferredColorScheme(.light)
        }
    }
}
