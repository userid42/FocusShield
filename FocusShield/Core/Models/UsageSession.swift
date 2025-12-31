import Foundation

// MARK: - Usage Session

struct UsageSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    var appTokenData: Data?            // Encoded ApplicationToken
    var appName: String?               // Display name if available
    var durationSeconds: Int
    var wasBlocked: Bool
    var limitId: UUID?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        appTokenData: Data? = nil,
        appName: String? = nil,
        durationSeconds: Int = 0,
        wasBlocked: Bool = false,
        limitId: UUID? = nil
    ) {
        self.id = id
        self.date = date
        self.appTokenData = appTokenData
        self.appName = appName
        self.durationSeconds = durationSeconds
        self.wasBlocked = wasBlocked
        self.limitId = limitId
    }

    var durationMinutes: Int {
        durationSeconds / 60
    }

    var displayDuration: String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Usage Summary

struct UsageSummary: Codable {
    let date: Date
    var totalMinutes: Int
    var appUsage: [String: Int]  // App name to minutes
    var blockedAttempts: Int
    var graceUsedCount: Int
    var doneChosenCount: Int

    init(
        date: Date = Date(),
        totalMinutes: Int = 0,
        appUsage: [String: Int] = [:],
        blockedAttempts: Int = 0,
        graceUsedCount: Int = 0,
        doneChosenCount: Int = 0
    ) {
        self.date = date
        self.totalMinutes = totalMinutes
        self.appUsage = appUsage
        self.blockedAttempts = blockedAttempts
        self.graceUsedCount = graceUsedCount
        self.doneChosenCount = doneChosenCount
    }

    var displayTotalTime: String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var topApps: [(String, Int)] {
        appUsage.sorted { $0.value > $1.value }
    }
}
