import Foundation

// MARK: - Insight Type

enum InsightType: Codable {
    case pattern(day: String, time: String)
    case improvement(metric: String, changePercent: Int)
    case suggestion(action: String)
    case celebration(achievement: String)
    case warning(issue: String)

    var icon: String {
        switch self {
        case .pattern: return "chart.line.uptrend.xyaxis"
        case .improvement: return "arrow.up.right"
        case .suggestion: return "lightbulb.fill"
        case .celebration: return "star.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    var color: String {
        switch self {
        case .pattern: return "focusPrimary"
        case .improvement: return "success"
        case .suggestion: return "warning"
        case .celebration: return "focusSecondary"
        case .warning: return "danger"
        }
    }
}

// MARK: - Insight

struct Insight: Identifiable, Codable {
    let id: UUID
    let type: InsightType
    let message: String
    let actionLabel: String?
    let actionType: InsightActionType?
    let createdAt: Date
    var dismissed: Bool = false

    init(
        id: UUID = UUID(),
        type: InsightType,
        message: String,
        actionLabel: String? = nil,
        actionType: InsightActionType? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.message = message
        self.actionLabel = actionLabel
        self.actionType = actionType
        self.createdAt = createdAt
    }
}

// MARK: - Insight Action Type

enum InsightActionType: String, Codable {
    case addTimeWindow
    case adjustLimit
    case viewProgress
    case viewAchievement
    case contactPartner
}

// MARK: - Insight Generator

struct InsightGenerator {
    static func generateInsights(
        from records: [DailyRecord],
        limits: [AppLimit],
        progress: UserProgress
    ) -> [Insight] {
        var insights: [Insight] = []

        // Check for patterns
        if let patternInsight = detectPatterns(from: records) {
            insights.append(patternInsight)
        }

        // Check for improvements
        if let improvementInsight = detectImprovement(from: records) {
            insights.append(improvementInsight)
        }

        // Check for celebrations
        if let celebrationInsight = detectCelebration(from: progress) {
            insights.append(celebrationInsight)
        }

        // Check for warnings
        if let warningInsight = detectWarning(from: records, limits: limits) {
            insights.append(warningInsight)
        }

        return insights
    }

    private static func detectPatterns(from records: [DailyRecord]) -> Insight? {
        // Group failures by day of week
        let failures = records.filter { !$0.withinAllLimits }
        guard failures.count >= 2 else { return nil }

        let dayGroups = Dictionary(grouping: failures) { record in
            Calendar.current.component(.weekday, from: record.date)
        }

        if let worstDay = dayGroups.max(by: { $0.value.count < $1.value.count }),
           worstDay.value.count >= 2 {
            let dayName = Weekday(rawValue: worstDay.key)?.fullName ?? "Unknown"
            return Insight(
                type: .pattern(day: dayName, time: "evening"),
                message: "\(dayName)s are your hardest day. You've exceeded limits \(worstDay.value.count) times recently.",
                actionLabel: "Add evening block",
                actionType: .addTimeWindow
            )
        }

        return nil
    }

    private static func detectImprovement(from records: [DailyRecord]) -> Insight? {
        guard records.count >= 7 else { return nil }

        let thisWeek = records.suffix(7)
        let lastWeek = records.dropLast(7).suffix(7)

        guard lastWeek.count >= 7 else { return nil }

        let thisWeekSuccess = thisWeek.filter { $0.withinAllLimits }.count
        let lastWeekSuccess = lastWeek.filter { $0.withinAllLimits }.count

        if thisWeekSuccess > lastWeekSuccess {
            let improvement = thisWeekSuccess - lastWeekSuccess
            let percent = Int((Double(improvement) / max(1, Double(lastWeekSuccess))) * 100)

            return Insight(
                type: .improvement(metric: "days within limits", changePercent: percent),
                message: "You've kept \(percent)% more days within limits this week vs last week.",
                actionLabel: nil,
                actionType: nil
            )
        }

        return nil
    }

    private static func detectCelebration(from progress: UserProgress) -> Insight? {
        // Celebrate streak milestones
        let milestones = [3, 7, 14, 21, 30, 60, 90]

        if milestones.contains(progress.currentStreak) {
            return Insight(
                type: .celebration(achievement: "\(progress.currentStreak)-day streak"),
                message: "You're on a \(progress.currentStreak)-day streak. Keep it going!",
                actionLabel: nil,
                actionType: nil
            )
        }

        return nil
    }

    private static func detectWarning(from records: [DailyRecord], limits: [AppLimit]) -> Insight? {
        // Check if any limit is consistently being exceeded
        let recentRecords = records.suffix(7)
        let exceededCount = recentRecords.filter { $0.limitExceededCount > 0 }.count

        if exceededCount >= 5 {
            return Insight(
                type: .warning(issue: "frequent limit exceeded"),
                message: "You've exceeded limits \(exceededCount) of the last 7 days. Consider adjusting your limits.",
                actionLabel: "Adjust limits",
                actionType: .adjustLimit
            )
        }

        return nil
    }
}
