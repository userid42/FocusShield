import DeviceActivity
import ManagedSettings
import Foundation

/// Extension that monitors device activity and triggers shield actions when limits are reached
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let store = ManagedSettingsStore()
    private let userDefaults = UserDefaults(suiteName: "group.com.focusshield.app")

    /// Called when a device activity schedule starts
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        // Apply shields based on activity
        applyShieldsForActivity(activity)

        // Log the event
        logEvent(.scheduleStarted, activity: activity)
    }

    /// Called when a device activity schedule ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        // Remove shields when schedule ends
        removeShieldsForActivity(activity)

        // Log the event
        logEvent(.scheduleEnded, activity: activity)
    }

    /// Called when a threshold is reached during an activity
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        // Shield the app when threshold is reached
        handleThresholdReached(event: event, activity: activity)

        // Log the event
        logEvent(.thresholdReached, activity: activity, event: event)
    }

    /// Called periodically during activity intervals for warning thresholds
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)

        // Could send a notification warning
        sendWarningNotification(for: activity)
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)

        // End of day reminder if applicable
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)

        // Warn user they're approaching limit
        sendApproachingLimitNotification(event: event, activity: activity)
    }

    // MARK: - Private Helpers

    private func applyShieldsForActivity(_ activity: DeviceActivityName) {
        // Load app tokens from shared storage
        guard let data = userDefaults?.data(forKey: "shielded_apps_\(activity.rawValue)"),
              let appTokens = try? JSONDecoder().decode(Set<ApplicationToken>.self, from: data) else {
            return
        }

        store.shield.applications = appTokens
    }

    private func removeShieldsForActivity(_ activity: DeviceActivityName) {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    private func handleThresholdReached(event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        // Apply shield to the specific app that reached threshold
        guard let data = userDefaults?.data(forKey: "threshold_apps_\(event.rawValue)"),
              let appTokens = try? JSONDecoder().decode(Set<ApplicationToken>.self, from: data) else {
            return
        }

        // Add these apps to the shield
        var currentShielded = store.shield.applications ?? []
        currentShielded.formUnion(appTokens)
        store.shield.applications = currentShielded

        // Record that threshold was reached
        recordThresholdReached(event: event)
    }

    private func recordThresholdReached(event: DeviceActivityEvent.Name) {
        var thresholdEvents = userDefaults?.array(forKey: "threshold_events") as? [[String: Any]] ?? []
        thresholdEvents.append([
            "event": event.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ])
        userDefaults?.set(thresholdEvents, forKey: "threshold_events")
    }

    private func logEvent(_ type: MonitorEventType, activity: DeviceActivityName, event: DeviceActivityEvent.Name? = nil) {
        var logs = userDefaults?.array(forKey: "activity_logs") as? [[String: Any]] ?? []
        var logEntry: [String: Any] = [
            "type": type.rawValue,
            "activity": activity.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        if let event = event {
            logEntry["event"] = event.rawValue
        }
        logs.append(logEntry)

        // Keep only last 100 logs
        if logs.count > 100 {
            logs = Array(logs.suffix(100))
        }

        userDefaults?.set(logs, forKey: "activity_logs")
    }

    private func sendWarningNotification(for activity: DeviceActivityName) {
        // Would post to notification center
        let content = [
            "title": "Focus Time Starting",
            "body": "Your scheduled focus time is about to begin.",
            "activity": activity.rawValue
        ]
        userDefaults?.set(content, forKey: "pending_notification")
    }

    private func sendApproachingLimitNotification(event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        let content = [
            "title": "Approaching Limit",
            "body": "You're almost at your daily limit.",
            "event": event.rawValue
        ]
        userDefaults?.set(content, forKey: "pending_notification")
    }
}

// MARK: - Monitor Event Type

enum MonitorEventType: String {
    case scheduleStarted = "schedule_started"
    case scheduleEnded = "schedule_ended"
    case thresholdReached = "threshold_reached"
    case warningTriggered = "warning_triggered"
}

// MARK: - Application Token Codable Extension

extension ApplicationToken: Codable {
    public init(from decoder: Decoder) throws {
        // ApplicationToken doesn't have public init, this is a placeholder
        fatalError("ApplicationToken cannot be decoded directly")
    }

    public func encode(to encoder: Encoder) throws {
        // Encode the token data
        var container = encoder.singleValueContainer()
        try container.encode(self.hashValue)
    }
}
