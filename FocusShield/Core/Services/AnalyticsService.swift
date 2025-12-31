import Foundation

// MARK: - Analytics Service

@MainActor
class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()

    private let persistence = PersistenceService.shared

    private init() {}

    // MARK: - Track Events

    func track(_ event: AnalyticsEvent) {
        // In production, this would send to analytics backend
        print("Analytics: \(event.name) - \(event.properties)")

        // Store locally for debugging
        storeEvent(event)
    }

    private func storeEvent(_ event: AnalyticsEvent) {
        var events = UserDefaults.appGroup.array(forKey: "analyticsEvents") as? [[String: Any]] ?? []
        events.append([
            "name": event.name,
            "properties": event.properties,
            "timestamp": Date().timeIntervalSince1970
        ])

        // Keep last 100 events
        if events.count > 100 {
            events = Array(events.suffix(100))
        }

        UserDefaults.appGroup.set(events, forKey: "analyticsEvents")
    }

    // MARK: - Common Events

    func trackOnboardingStep(_ step: String) {
        track(AnalyticsEvent(
            name: "onboarding_step",
            properties: ["step": step]
        ))
    }

    func trackOnboardingComplete(goal: UserGoal?, mode: CommitmentMode) {
        track(AnalyticsEvent(
            name: "onboarding_complete",
            properties: [
                "goal": goal?.rawValue ?? "none",
                "mode": mode.rawValue
            ]
        ))
    }

    func trackShieldOption(_ option: ShieldOption, appName: String?) {
        track(AnalyticsEvent(
            name: "shield_option_selected",
            properties: [
                "option": option.analyticsName,
                "app": appName ?? "unknown"
            ]
        ))
    }

    func trackLimitExceeded(limitName: String) {
        track(AnalyticsEvent(
            name: "limit_exceeded",
            properties: ["limit": limitName]
        ))
    }

    func trackAchievementUnlocked(_ achievement: AchievementDefinition) {
        track(AnalyticsEvent(
            name: "achievement_unlocked",
            properties: ["achievement": achievement.rawValue]
        ))
    }

    func trackStreakUpdate(currentStreak: Int, longestStreak: Int) {
        track(AnalyticsEvent(
            name: "streak_update",
            properties: [
                "current": currentStreak,
                "longest": longestStreak
            ]
        ))
    }

    func trackPartnerAdded(method: String) {
        track(AnalyticsEvent(
            name: "partner_added",
            properties: ["method": method]
        ))
    }

    func trackPartnerRemoved() {
        track(AnalyticsEvent(name: "partner_removed", properties: [:]))
    }

    // MARK: - Generate Insights

    func generateWeeklyInsights() -> [Insight] {
        let records = persistence.userProgress.weeklyHistory
        let limits = persistence.limits
        let progress = persistence.userProgress

        return InsightGenerator.generateInsights(
            from: records,
            limits: limits,
            progress: progress
        )
    }

    // MARK: - Weekly Summary

    func generateWeeklySummary() -> WeeklySummary {
        let records = persistence.userProgress.weeklyHistory

        let calendar = Calendar.current
        let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) ?? Date()

        return WeeklySummary(records: records, weekStartDate: startOfWeek)
    }
}

// MARK: - Analytics Event

struct AnalyticsEvent {
    let name: String
    let properties: [String: Any]

    init(name: String, properties: [String: Any] = [:]) {
        self.name = name
        self.properties = properties
    }
}
