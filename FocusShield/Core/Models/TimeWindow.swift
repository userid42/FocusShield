import Foundation

// MARK: - Time Window (Schedule)

struct TimeWindow: Codable, Identifiable {
    let id: UUID
    var name: String
    var startTime: DateComponents
    var endTime: DateComponents
    var activeDays: Set<Int>              // 1-7 (Sunday-Saturday)
    var blockedAppTokensData: Data?
    var blockedCategoryTokensData: Data?
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        startTime: DateComponents = DateComponents(hour: 22, minute: 0),
        endTime: DateComponents = DateComponents(hour: 6, minute: 0),
        activeDays: Set<Int> = Set(1...7),
        blockedAppTokensData: Data? = nil,
        blockedCategoryTokensData: Data? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.activeDays = activeDays
        self.blockedAppTokensData = blockedAppTokensData
        self.blockedCategoryTokensData = blockedCategoryTokensData
        self.isEnabled = isEnabled
    }

    var displayTimeRange: String {
        guard let startHour = startTime.hour,
              let endHour = endTime.hour else {
            return "Not set"
        }

        let startMinute = startTime.minute ?? 0
        let endMinute = endTime.minute ?? 0

        let startString = formatTime(hour: startHour, minute: startMinute)
        let endString = formatTime(hour: endHour, minute: endMinute)

        return "\(startString) - \(endString)"
    }

    var displayDays: String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let sortedDays = activeDays.sorted()

        if sortedDays.count == 7 {
            return "Every day"
        } else if sortedDays == [2, 3, 4, 5, 6] {
            return "Weekdays"
        } else if sortedDays == [1, 7] {
            return "Weekends"
        } else {
            return sortedDays.compactMap { day in
                guard day >= 1 && day <= 7 else { return nil }
                return dayNames[day - 1]
            }.joined(separator: ", ")
        }
    }

    func isActiveNow() -> Bool {
        guard isEnabled else { return false }

        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)

        guard activeDays.contains(currentWeekday) else { return false }

        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)

        guard let startHour = startTime.hour,
              let endHour = endTime.hour else { return false }

        let startMinute = startTime.minute ?? 0
        let endMinute = endTime.minute ?? 0

        let currentTotalMinutes = currentHour * 60 + currentMinute
        let startTotalMinutes = startHour * 60 + startMinute
        let endTotalMinutes = endHour * 60 + endMinute

        if startTotalMinutes <= endTotalMinutes {
            // Same day range (e.g., 9 AM - 5 PM)
            return currentTotalMinutes >= startTotalMinutes && currentTotalMinutes < endTotalMinutes
        } else {
            // Overnight range (e.g., 10 PM - 6 AM)
            return currentTotalMinutes >= startTotalMinutes || currentTotalMinutes < endTotalMinutes
        }
    }

    private func formatTime(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
}

// MARK: - Weekday Helper

enum Weekday: Int, CaseIterable, Codable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }

    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }

    var letter: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}
