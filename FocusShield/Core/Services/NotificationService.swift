import Foundation
import UserNotifications

// MARK: - Notification Service

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized: Bool = false

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            Task { @MainActor in
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestAuthorization() async throws {
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        )
        isAuthorized = granted
    }

    // MARK: - Schedule Notifications

    func scheduleReminderNotification(
        title: String,
        body: String,
        at date: Date,
        identifier: String
    ) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleStreakReminder() {
        scheduleReminderNotification(
            title: "Keep your streak going!",
            body: "You're doing great. Stay within limits today.",
            at: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!,
            identifier: "streak_reminder"
        )
    }

    func scheduleDailyReflection() {
        scheduleReminderNotification(
            title: "Daily Check-in",
            body: "How did you do today? Take a moment to reflect.",
            at: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!,
            identifier: "daily_reflection"
        )
    }

    // MARK: - Limit Notifications

    func notifyLimitApproaching(appName: String, minutesRemaining: Int) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Limit Approaching"
        content.body = "\(minutesRemaining) minutes left for \(appName) today"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "limit_approaching_\(appName)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func notifyLimitReached(appName: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Limit Reached"
        content.body = "You've used your \(appName) time for today"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "limit_reached_\(appName)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Achievement Notifications

    func notifyAchievementUnlocked(_ achievement: AchievementDefinition) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked!"
        content.body = "\(achievement.title): \(achievement.description)"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("achievement.wav"))

        let request = UNNotificationRequest(
            identifier: "achievement_\(achievement.rawValue)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel Notifications

    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
