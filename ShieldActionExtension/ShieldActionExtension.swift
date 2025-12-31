import ManagedSettings
import ManagedSettingsUI

/// Extension that handles shield button actions when user interacts with the shield UI
class ShieldActionExtension: ShieldActionDelegate {

    private let userDefaults = UserDefaults(suiteName: "group.com.focusshield.app")

    /// Called when user taps the primary button on the shield
    override func handle(action: ShieldAction, for application: Application, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // "I'm Done" - user chose to leave
            logShieldAction(type: .done, application: application)
            completionHandler(.close)

        case .secondaryButtonPressed:
            // "Options" - defer to app for more options
            logShieldAction(type: .options, application: application)
            completionHandler(.defer)

        @unknown default:
            completionHandler(.close)
        }
    }

    /// Called when user taps the primary button on a category shield
    override func handle(action: ShieldAction, for category: ActivityCategory, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            logShieldAction(type: .done, category: category)
            completionHandler(.close)

        case .secondaryButtonPressed:
            logShieldAction(type: .options, category: category)
            completionHandler(.defer)

        @unknown default:
            completionHandler(.close)
        }
    }

    /// Called when user taps the primary button on a web domain shield
    override func handle(action: ShieldAction, for webDomain: WebDomain, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            logShieldAction(type: .done, webDomain: webDomain)
            completionHandler(.close)

        case .secondaryButtonPressed:
            logShieldAction(type: .options, webDomain: webDomain)
            completionHandler(.defer)

        @unknown default:
            completionHandler(.close)
        }
    }

    // MARK: - Private Helpers

    private func logShieldAction(type: ShieldActionType, application: Application? = nil, category: ActivityCategory? = nil, webDomain: WebDomain? = nil) {
        var logs = userDefaults?.array(forKey: "shield_action_logs") as? [[String: Any]] ?? []

        var logEntry: [String: Any] = [
            "type": type.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]

        if let app = application {
            logEntry["application"] = app.localizedDisplayName ?? "Unknown App"
        }
        if let cat = category {
            logEntry["category"] = cat.localizedDisplayName ?? "Unknown Category"
        }
        if let domain = webDomain {
            logEntry["webDomain"] = domain.domain ?? "Unknown Domain"
        }

        logs.append(logEntry)

        // Keep only last 200 logs
        if logs.count > 200 {
            logs = Array(logs.suffix(200))
        }

        userDefaults?.set(logs, forKey: "shield_action_logs")

        // Update counters for analytics
        updateActionCounter(type: type)
    }

    private func updateActionCounter(type: ShieldActionType) {
        let key = "shield_\(type.rawValue)_count"
        let currentCount = userDefaults?.integer(forKey: key) ?? 0
        userDefaults?.set(currentCount + 1, forKey: key)

        // Also track daily counts
        let today = Calendar.current.startOfDay(for: Date())
        let dailyKey = "shield_\(type.rawValue)_\(today.timeIntervalSince1970)"
        let dailyCount = userDefaults?.integer(forKey: dailyKey) ?? 0
        userDefaults?.set(dailyCount + 1, forKey: dailyKey)
    }
}

// MARK: - Shield Action Type

enum ShieldActionType: String {
    case done = "done"
    case options = "options"
    case grace = "grace"
    case emergency = "emergency"
}
