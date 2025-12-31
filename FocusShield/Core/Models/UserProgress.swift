import Foundation

// MARK: - User Progress

struct UserProgress: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalDaysWithinLimits: Int = 0
    var totalDaysTracked: Int = 0
    var weeklyHistory: [DailyRecord] = []
    var lastUpdated: Date = Date()

    var successRate: Double {
        guard totalDaysTracked > 0 else { return 0 }
        return Double(totalDaysWithinLimits) / Double(totalDaysTracked)
    }

    var displaySuccessRate: String {
        let percentage = Int(successRate * 100)
        return "\(percentage)%"
    }

    mutating func recordDay(_ record: DailyRecord) {
        // Update weekly history (keep last 7 days)
        weeklyHistory.append(record)
        if weeklyHistory.count > 7 {
            weeklyHistory.removeFirst()
        }

        totalDaysTracked += 1

        if record.withinAllLimits {
            totalDaysWithinLimits += 1
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            // Check if we should do a soft reset
            if currentStreak > 0 {
                // First failure: warning only (keep streak for now)
                // This could be enhanced with more sophisticated logic
                currentStreak = 0
            }
        }

        lastUpdated = Date()
    }

    mutating func softResetStreak() {
        // Allow user to acknowledge streak break and start fresh
        currentStreak = 0
    }
}

// MARK: - Streak Status

enum StreakStatus {
    case none
    case building(days: Int)
    case strong(days: Int)
    case record(days: Int)

    init(currentStreak: Int, longestStreak: Int) {
        if currentStreak == 0 {
            self = .none
        } else if currentStreak >= longestStreak && currentStreak > 7 {
            self = .record(days: currentStreak)
        } else if currentStreak >= 7 {
            self = .strong(days: currentStreak)
        } else {
            self = .building(days: currentStreak)
        }
    }

    var message: String {
        switch self {
        case .none:
            return "Start your streak today"
        case .building(let days):
            return "Building momentum: \(days) day\(days == 1 ? "" : "s")"
        case .strong(let days):
            return "\(days) days strong!"
        case .record(let days):
            return "New record: \(days) days!"
        }
    }

    var icon: String {
        switch self {
        case .none:
            return "flame"
        case .building:
            return "flame.fill"
        case .strong:
            return "flame.fill"
        case .record:
            return "star.fill"
        }
    }

    var color: String {
        switch self {
        case .none:
            return "neutral"
        case .building:
            return "warning"
        case .strong:
            return "focusPrimary"
        case .record:
            return "success"
        }
    }
}

// MARK: - Reset Ritual Reason

enum StreakBreakReason: String, CaseIterable, Identifiable {
    case stressfulDay = "Stressful day"
    case specialOccasion = "Special occasion"
    case justSlipped = "Just slipped"
    case technicalIssue = "Technical issue"
    case other = "Other"

    var id: String { rawValue }
}

struct StreakResetRitual: Codable {
    let date: Date
    let previousStreak: Int
    let reason: String
    var adjustment: String?

    init(
        date: Date = Date(),
        previousStreak: Int,
        reason: String,
        adjustment: String? = nil
    ) {
        self.date = date
        self.previousStreak = previousStreak
        self.reason = reason
        self.adjustment = adjustment
    }
}
