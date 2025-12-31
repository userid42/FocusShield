import SwiftUI

struct NotificationPrefsView: View {
    @EnvironmentObject var persistence: PersistenceService

    @State private var dailyReminders = true
    @State private var budgetAlerts = true
    @State private var streakReminders = true
    @State private var weeklyDigest = true
    @State private var achievementAlerts = true
    @State private var partnerUpdates = true

    @State private var reminderTime = Date()
    @State private var budgetThreshold: Double = 0.8

    var body: some View {
        List {
            // Daily Reminders
            Section {
                Toggle(isOn: $dailyReminders) {
                    NotificationToggleRow(
                        icon: "bell.fill",
                        iconColor: .focusPrimary,
                        title: "Daily Reminders",
                        subtitle: "Get reminded of your focus goals"
                    )
                }
                .tint(.focusPrimary)

                if dailyReminders {
                    DatePicker(
                        "Reminder Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .padding(.leading, 44)
                }
            }

            // Usage Alerts
            Section {
                Toggle(isOn: $budgetAlerts) {
                    NotificationToggleRow(
                        icon: "chart.pie.fill",
                        iconColor: .warning,
                        title: "Budget Alerts",
                        subtitle: "When approaching daily limits"
                    )
                }
                .tint(.focusPrimary)

                if budgetAlerts {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Alert at \(Int(budgetThreshold * 100))% of limit")
                            .font(.labelMedium)
                            .foregroundColor(.neutral)

                        Slider(value: $budgetThreshold, in: 0.5...0.95, step: 0.05)
                            .tint(.focusPrimary)
                    }
                    .padding(.leading, 44)
                }
            } header: {
                Text("Usage Notifications")
            }

            // Motivation
            Section {
                Toggle(isOn: $streakReminders) {
                    NotificationToggleRow(
                        icon: "flame.fill",
                        iconColor: .danger,
                        title: "Streak Reminders",
                        subtitle: "Don't break your streak!"
                    )
                }
                .tint(.focusPrimary)

                Toggle(isOn: $achievementAlerts) {
                    NotificationToggleRow(
                        icon: "trophy.fill",
                        iconColor: .warning,
                        title: "Achievement Unlocked",
                        subtitle: "Celebrate your milestones"
                    )
                }
                .tint(.focusPrimary)

                Toggle(isOn: $weeklyDigest) {
                    NotificationToggleRow(
                        icon: "calendar",
                        iconColor: .focusSecondary,
                        title: "Weekly Digest",
                        subtitle: "Sunday progress summary"
                    )
                }
                .tint(.focusPrimary)
            } header: {
                Text("Motivation")
            }

            // Accountability
            Section {
                Toggle(isOn: $partnerUpdates) {
                    NotificationToggleRow(
                        icon: "person.2.fill",
                        iconColor: .success,
                        title: "Partner Updates",
                        subtitle: "When your partner responds"
                    )
                }
                .tint(.focusPrimary)
            } header: {
                Text("Accountability")
            } footer: {
                Text("Your partner will be notified based on their own notification preferences.")
            }

            // System Settings
            Section {
                Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(.neutral)
                        Text("Open System Settings")
                            .font(.bodyMedium)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.neutral)
                    }
                }
            } footer: {
                Text("Manage notification permissions and sounds in iOS Settings.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: dailyReminders) { _, newValue in
            savePreferences()
        }
        .onChange(of: budgetAlerts) { _, newValue in
            savePreferences()
        }
        .onChange(of: streakReminders) { _, newValue in
            savePreferences()
        }
        .onChange(of: weeklyDigest) { _, newValue in
            savePreferences()
        }
        .onChange(of: achievementAlerts) { _, newValue in
            savePreferences()
        }
        .onChange(of: partnerUpdates) { _, newValue in
            savePreferences()
        }
    }

    private func savePreferences() {
        // Save to persistence
        persistence.updateNotificationPreferences(
            NotificationPreferences(
                dailyReminders: dailyReminders,
                reminderTime: reminderTime,
                budgetAlerts: budgetAlerts,
                budgetThreshold: budgetThreshold,
                streakReminders: streakReminders,
                weeklyDigest: weeklyDigest,
                achievementAlerts: achievementAlerts,
                partnerUpdates: partnerUpdates
            )
        )
    }
}

// MARK: - Notification Toggle Row

struct NotificationToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.bodyMedium)

                Text(subtitle)
                    .font(.labelSmall)
                    .foregroundColor(.neutral)
            }
        }
    }
}

// MARK: - Notification Preferences Model

struct NotificationPreferences: Codable {
    var dailyReminders: Bool
    var reminderTime: Date
    var budgetAlerts: Bool
    var budgetThreshold: Double
    var streakReminders: Bool
    var weeklyDigest: Bool
    var achievementAlerts: Bool
    var partnerUpdates: Bool

    static var `default`: NotificationPreferences {
        NotificationPreferences(
            dailyReminders: true,
            reminderTime: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
            budgetAlerts: true,
            budgetThreshold: 0.8,
            streakReminders: true,
            weeklyDigest: true,
            achievementAlerts: true,
            partnerUpdates: true
        )
    }
}

#Preview {
    NavigationStack {
        NotificationPrefsView()
            .environmentObject(PersistenceService.shared)
    }
}
