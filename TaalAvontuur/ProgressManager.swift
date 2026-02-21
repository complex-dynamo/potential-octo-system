import SwiftUI

/// Tracks learning progress and star rewards using UserDefaults
class ProgressManager: ObservableObject {
    @Published var totalStars: Int {
        didSet { UserDefaults.standard.set(totalStars, forKey: "totalStars") }
    }

    private let defaults = UserDefaults.standard

    init() {
        self.totalStars = UserDefaults.standard.integer(forKey: "totalStars")
    }

    // MARK: - Stars

    func addStars(_ count: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            totalStars += count
        }
    }

    // MARK: - Activity Completion

    /// Key for tracking completion: "world_{worldId}_{activityType}_{language}"
    private func completionKey(worldId: Int, activity: ActivityType, language: LearningLanguage) -> String {
        "completed_\(worldId)_\(activity.rawValue)_\(language.rawValue)"
    }

    func isCompleted(worldId: Int, activity: ActivityType, language: LearningLanguage) -> Bool {
        defaults.bool(forKey: completionKey(worldId: worldId, activity: activity, language: language))
    }

    func markCompleted(worldId: Int, activity: ActivityType, language: LearningLanguage) {
        let key = completionKey(worldId: worldId, activity: activity, language: language)
        if !defaults.bool(forKey: key) {
            defaults.set(true, forKey: key)
            addStars(starsForActivity(activity))
        }
    }

    /// Number of stars awarded per activity type
    func starsForActivity(_ activity: ActivityType) -> Int {
        switch activity {
        case .learn: return 1
        case .memory: return 2
        case .quiz: return 2
        case .draw: return 1
        }
    }

    // MARK: - World Progress

    /// Returns how many activities are completed for a world (across both languages)
    func completedActivitiesCount(worldId: Int, language: LearningLanguage) -> Int {
        ActivityType.allCases.filter { isCompleted(worldId: worldId, activity: $0, language: language) }.count
    }

    /// Returns fraction of completion for a world
    func worldProgress(worldId: Int, language: LearningLanguage) -> Double {
        Double(completedActivitiesCount(worldId: worldId, language: language)) / Double(ActivityType.allCases.count)
    }

    // MARK: - Reset (for testing)

    func resetAll() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        totalStars = 0
    }
}
