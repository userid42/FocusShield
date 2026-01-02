import Foundation

// MARK: - Grace Pool

struct GracePool: Codable {
    var dailyGracesRemaining: Int = 3     // Resets at midnight
    var graceMinutes: Int = 2              // Each grace grants 2 min
    var lastResetDate: Date
    var totalGracesUsedToday: Int = 0

    init(
        dailyGracesRemaining: Int = 3,
        graceMinutes: Int = 2,
        lastResetDate: Date = Date(),
        totalGracesUsedToday: Int = 0
    ) {
        self.dailyGracesRemaining = dailyGracesRemaining
        self.graceMinutes = graceMinutes
        self.lastResetDate = lastResetDate
        self.totalGracesUsedToday = totalGracesUsedToday
    }

    mutating func useGrace() -> Bool {
        resetIfNeeded()
        guard dailyGracesRemaining > 0 else { return false }
        dailyGracesRemaining -= 1
        totalGracesUsedToday += 1
        return true
    }

    mutating func resetIfNeeded() {
        if !Calendar.current.isDateInToday(lastResetDate) {
            dailyGracesRemaining = 3
            totalGracesUsedToday = 0
            lastResetDate = Date()
        }
    }

    /// Check if graces are remaining (accounts for day change)
    /// Note: This is a computed property that checks without mutating
    var hasGracesRemaining: Bool {
        // Check if we need to reset (new day)
        if !Calendar.current.isDateInToday(lastResetDate) {
            return true // Will have full graces after reset
        }
        return dailyGracesRemaining > 0
    }

    /// Returns the actual remaining count accounting for potential reset
    var effectiveGracesRemaining: Int {
        if !Calendar.current.isDateInToday(lastResetDate) {
            return 3 // Will reset to full
        }
        return dailyGracesRemaining
    }

    var displayRemaining: String {
        let remaining = effectiveGracesRemaining
        if remaining == 0 {
            return "No graces left today"
        } else if remaining == 1 {
            return "1 grace remaining"
        } else {
            return "\(remaining) graces remaining"
        }
    }
}

// MARK: - Grace Session

struct GraceSession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    let durationMinutes: Int
    let limitId: UUID
    var appName: String?
    var completed: Bool = false

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        durationMinutes: Int = 2,
        limitId: UUID,
        appName: String? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.durationMinutes = durationMinutes
        self.limitId = limitId
        self.appName = appName
    }

    var endTime: Date {
        Calendar.current.date(byAdding: .minute, value: durationMinutes, to: startTime) ?? startTime
    }

    var isExpired: Bool {
        Date() > endTime
    }

    var remainingSeconds: Int {
        let remaining = endTime.timeIntervalSince(Date())
        return max(0, Int(remaining))
    }
}
