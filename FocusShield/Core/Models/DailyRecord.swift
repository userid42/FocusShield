import Foundation

// MARK: - Daily Record

struct DailyRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    var withinAllLimits: Bool
    var totalScreenTimeMinutes: Int
    var limitExceededCount: Int
    var graceUsedCount: Int
    var emergencyAccessCount: Int
    var doneChosenCount: Int              // Times user chose "I'm Done"
    var extensionRequestedCount: Int

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        withinAllLimits: Bool = true,
        totalScreenTimeMinutes: Int = 0,
        limitExceededCount: Int = 0,
        graceUsedCount: Int = 0,
        emergencyAccessCount: Int = 0,
        doneChosenCount: Int = 0,
        extensionRequestedCount: Int = 0
    ) {
        self.id = id
        self.date = date
        self.withinAllLimits = withinAllLimits
        self.totalScreenTimeMinutes = totalScreenTimeMinutes
        self.limitExceededCount = limitExceededCount
        self.graceUsedCount = graceUsedCount
        self.emergencyAccessCount = emergencyAccessCount
        self.doneChosenCount = doneChosenCount
        self.extensionRequestedCount = extensionRequestedCount
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var displayDate: String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
    }

    var shortDisplayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    var displayScreenTime: String {
        let hours = totalScreenTimeMinutes / 60
        let minutes = totalScreenTimeMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var successScore: Double {
        // Calculate a score based on behavior
        var score = 1.0

        // Penalize for exceeding limits
        score -= Double(limitExceededCount) * 0.2

        // Penalize for emergency access
        score -= Double(emergencyAccessCount) * 0.3

        // Bonus for choosing "I'm Done"
        score += Double(doneChosenCount) * 0.05

        return max(0, min(1, score))
    }
}

// MARK: - Weekly Summary

struct WeeklySummary {
    let records: [DailyRecord]
    let weekStartDate: Date

    var daysWithinLimits: Int {
        records.filter { $0.withinAllLimits }.count
    }

    var totalDoneChosen: Int {
        records.reduce(0) { $0 + $1.doneChosenCount }
    }

    var totalEmergencyAccess: Int {
        records.reduce(0) { $0 + $1.emergencyAccessCount }
    }

    var averageScreenTime: Int {
        guard !records.isEmpty else { return 0 }
        let total = records.reduce(0) { $0 + $1.totalScreenTimeMinutes }
        return total / records.count
    }

    var successRate: Double {
        guard !records.isEmpty else { return 0 }
        return Double(daysWithinLimits) / Double(records.count)
    }

    var hardestDay: Weekday? {
        let exceededByDay = Dictionary(grouping: records.filter { !$0.withinAllLimits }) { record in
            Calendar.current.component(.weekday, from: record.date)
        }

        guard let maxDay = exceededByDay.max(by: { $0.value.count < $1.value.count }) else {
            return nil
        }

        return Weekday(rawValue: maxDay.key)
    }

    var displayAverageScreenTime: String {
        let hours = averageScreenTime / 60
        let minutes = averageScreenTime % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
