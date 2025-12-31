import Foundation

// MARK: - App Limit Model

struct AppLimit: Codable, Identifiable {
    let id: UUID
    var name: String                        // User-defined name
    var appTokensData: Data?                // Encoded FamilyActivitySelection application tokens
    var categoryTokensData: Data?           // Encoded category tokens
    var webDomainTokensData: Data?          // Encoded web domain tokens
    var dailyMinutes: Int
    var weekendMinutes: Int?
    var isActive: Bool
    var createdAt: Date
    var lastModified: Date

    // Usage tracking (updated externally)
    var usedMinutesToday: Int = 0

    init(
        id: UUID = UUID(),
        name: String = "",
        appTokensData: Data? = nil,
        categoryTokensData: Data? = nil,
        webDomainTokensData: Data? = nil,
        dailyMinutes: Int = 30,
        weekendMinutes: Int? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        lastModified: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.appTokensData = appTokensData
        self.categoryTokensData = categoryTokensData
        self.webDomainTokensData = webDomainTokensData
        self.dailyMinutes = dailyMinutes
        self.weekendMinutes = weekendMinutes
        self.isActive = isActive
        self.createdAt = createdAt
        self.lastModified = lastModified
    }

    // Computed properties
    var displayName: String {
        name.isEmpty ? "Limit" : name
    }

    var progress: Double {
        guard dailyMinutes > 0 else { return 0 }
        return Double(usedMinutesToday) / Double(effectiveDailyLimit)
    }

    var effectiveDailyLimit: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let isWeekend = weekday == 1 || weekday == 7

        if isWeekend, let weekendLimit = weekendMinutes {
            return weekendLimit
        }
        return dailyMinutes
    }

    var remainingMinutes: Int {
        max(0, effectiveDailyLimit - usedMinutesToday)
    }

    var isExceeded: Bool {
        usedMinutesToday >= effectiveDailyLimit
    }

    var statusColor: String {
        if progress >= 1.0 { return "danger" }
        if progress >= 0.8 { return "warning" }
        return "focusPrimary"
    }
}

// MARK: - Sample Data

extension AppLimit {
    static let sampleLimits: [AppLimit] = [
        AppLimit(
            name: "Social Media",
            dailyMinutes: 30,
            weekendMinutes: 45
        ),
        AppLimit(
            name: "Short-form Video",
            dailyMinutes: 15
        ),
        AppLimit(
            name: "Games",
            dailyMinutes: 30,
            weekendMinutes: 60
        )
    ]
}
