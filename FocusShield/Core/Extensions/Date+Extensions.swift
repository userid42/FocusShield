import Foundation

extension Date {
    /// Returns true if the date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Returns true if the date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Returns the start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns the end of day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    /// Returns a greeting based on the time of day
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }

    /// Formatted date string for display
    var displayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: self)
    }

    /// Short time string
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Relative time string (e.g., "2 hours ago")
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Returns the weekday (1 = Sunday, 7 = Saturday)
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    /// Returns dates for the current week
    static var currentWeekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: 1 - weekday, to: today)!

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }
}

extension DateComponents {
    /// Create time components from hour and minute
    static func time(hour: Int, minute: Int) -> DateComponents {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return components
    }
}
