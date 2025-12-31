import Foundation

// MARK: - Achievement Definition

enum AchievementDefinition: String, CaseIterable, Identifiable {
    case firstDay = "first_day"
    case streak3 = "streak_3"
    case streak7 = "streak_7"
    case streak14 = "streak_14"
    case streak30 = "streak_30"
    case done10 = "done_10"               // Chose "I'm Done" 10 times
    case done50 = "done_50"
    case done100 = "done_100"
    case noEmergency7 = "no_emergency_7"  // 7 days without emergency access
    case noEmergency30 = "no_emergency_30"
    case perfectWeek = "perfect_week"     // 7 days in a row within limits

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstDay: return "First Step"
        case .streak3: return "Building Momentum"
        case .streak7: return "One Week Strong"
        case .streak14: return "Two Weeks Deep"
        case .streak30: return "Monthly Master"
        case .done10: return "Choosing Well"
        case .done50: return "Pattern Breaker"
        case .done100: return "Autopilot Off"
        case .noEmergency7: return "Steady Hand"
        case .noEmergency30: return "Full Control"
        case .perfectWeek: return "Perfect Week"
        }
    }

    var description: String {
        switch self {
        case .firstDay: return "Complete your first day within limits"
        case .streak3: return "3 days in a row within limits"
        case .streak7: return "7 days in a row within limits"
        case .streak14: return "14 days in a row within limits"
        case .streak30: return "30 days in a row within limits"
        case .done10: return "Choose 'I'm Done' 10 times"
        case .done50: return "Choose 'I'm Done' 50 times"
        case .done100: return "Choose 'I'm Done' 100 times"
        case .noEmergency7: return "7 days without emergency access"
        case .noEmergency30: return "30 days without emergency access"
        case .perfectWeek: return "Stay within all limits for a full week"
        }
    }

    var iconName: String {
        switch self {
        case .firstDay: return "flag.fill"
        case .streak3, .streak7, .streak14, .streak30: return "flame.fill"
        case .done10, .done50, .done100: return "checkmark.seal.fill"
        case .noEmergency7, .noEmergency30: return "hand.raised.fill"
        case .perfectWeek: return "star.fill"
        }
    }

    var requiredValue: Int {
        switch self {
        case .firstDay: return 1
        case .streak3: return 3
        case .streak7, .noEmergency7, .perfectWeek: return 7
        case .streak14: return 14
        case .streak30, .noEmergency30: return 30
        case .done10: return 10
        case .done50: return 50
        case .done100: return 100
        }
    }

    var category: AchievementCategory {
        switch self {
        case .firstDay: return .milestone
        case .streak3, .streak7, .streak14, .streak30: return .streak
        case .done10, .done50, .done100: return .choices
        case .noEmergency7, .noEmergency30: return .selfControl
        case .perfectWeek: return .milestone
        }
    }
}

// MARK: - Achievement Category

enum AchievementCategory: String, CaseIterable {
    case milestone = "Milestones"
    case streak = "Streaks"
    case choices = "Good Choices"
    case selfControl = "Self-Control"

    var icon: String {
        switch self {
        case .milestone: return "flag.fill"
        case .streak: return "flame.fill"
        case .choices: return "checkmark.seal.fill"
        case .selfControl: return "hand.raised.fill"
        }
    }
}

// MARK: - Achievement (User's Progress)

struct Achievement: Codable, Identifiable {
    let id: String
    var isUnlocked: Bool = false
    var unlockedAt: Date?
    var currentProgress: Int = 0

    var definition: AchievementDefinition? {
        AchievementDefinition(rawValue: id)
    }

    var progress: Double {
        guard let def = definition else { return 0 }
        return min(1.0, Double(currentProgress) / Double(def.requiredValue))
    }

    var displayProgress: String {
        guard let def = definition else { return "" }
        if isUnlocked {
            return "Completed"
        }
        return "\(currentProgress)/\(def.requiredValue)"
    }

    init(definition: AchievementDefinition) {
        self.id = definition.rawValue
    }

    init(id: String, isUnlocked: Bool = false, unlockedAt: Date? = nil, currentProgress: Int = 0) {
        self.id = id
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        self.currentProgress = currentProgress
    }

    mutating func updateProgress(_ value: Int) {
        currentProgress = value
        if let def = definition, currentProgress >= def.requiredValue && !isUnlocked {
            isUnlocked = true
            unlockedAt = Date()
        }
    }
}

// MARK: - Achievements Manager

struct AchievementsManager: Codable {
    var achievements: [Achievement]

    init() {
        achievements = AchievementDefinition.allCases.map { Achievement(definition: $0) }
    }

    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }

    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }

    var unlockedCount: Int {
        unlockedAchievements.count
    }

    var totalCount: Int {
        achievements.count
    }

    mutating func updateAchievement(_ id: String, progress: Int) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].updateProgress(progress)
        }
    }

    func achievement(for definition: AchievementDefinition) -> Achievement? {
        achievements.first { $0.id == definition.rawValue }
    }
}
