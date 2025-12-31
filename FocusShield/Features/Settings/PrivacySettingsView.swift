import SwiftUI

struct PrivacySettingsView: View {
    @EnvironmentObject var persistence: PersistenceService

    @State private var shareUsageWithPartner = true
    @State private var shareDetailedApps = false
    @State private var allowAnalytics = true
    @State private var showingPermissionsSheet = false

    var body: some View {
        List {
            // Partner Sharing
            Section {
                Toggle(isOn: $shareUsageWithPartner) {
                    PrivacyToggleRow(
                        icon: "person.2.fill",
                        iconColor: .success,
                        title: "Share with Partner",
                        subtitle: "Partner can see your progress"
                    )
                }
                .tint(.focusPrimary)

                if shareUsageWithPartner {
                    Toggle(isOn: $shareDetailedApps) {
                        PrivacyToggleRow(
                            icon: "app.badge.fill",
                            iconColor: .focusPrimary,
                            title: "Detailed App Names",
                            subtitle: "Show specific apps, not just categories"
                        )
                    }
                    .tint(.focusPrimary)
                }
            } header: {
                Text("Partner Privacy")
            } footer: {
                Text("Your partner will only see the data you choose to share. They cannot access your device directly.")
            }

            // What Partner Sees
            Section {
                PartnerVisibilityRow(
                    title: "Total screen time",
                    isVisible: shareUsageWithPartner
                )
                PartnerVisibilityRow(
                    title: "Limit adherence",
                    isVisible: shareUsageWithPartner
                )
                PartnerVisibilityRow(
                    title: "Streak status",
                    isVisible: shareUsageWithPartner
                )
                PartnerVisibilityRow(
                    title: "Emergency access events",
                    isVisible: shareUsageWithPartner
                )
                PartnerVisibilityRow(
                    title: "Specific app names",
                    isVisible: shareDetailedApps && shareUsageWithPartner
                )
            } header: {
                Text("What Your Partner Sees")
            }

            // Analytics
            Section {
                Toggle(isOn: $allowAnalytics) {
                    PrivacyToggleRow(
                        icon: "chart.bar.fill",
                        iconColor: .focusSecondary,
                        title: "Usage Analytics",
                        subtitle: "Help improve FocusShield"
                    )
                }
                .tint(.focusPrimary)
            } header: {
                Text("Analytics")
            } footer: {
                Text("Anonymous usage data helps us improve the app. No personal information or app usage details are collected.")
            }

            // Permissions
            Section {
                Button {
                    showingPermissionsSheet = true
                } label: {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.focusPrimary)
                        Text("Review Permissions")
                            .font(.bodyMedium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.neutral)
                    }
                }
                .buttonStyle(.plain)
            } header: {
                Text("App Permissions")
            }

            // Data Storage
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Data Storage")
                            .font(.bodyMedium)
                        Text("All data stored locally on device")
                            .font(.labelSmall)
                            .foregroundColor(.neutral)
                    }
                    Spacer()
                    Image(systemName: "iphone")
                        .foregroundColor(.success)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Partner Sync")
                            .font(.bodyMedium)
                        Text("Shared via secure iCloud")
                            .font(.labelSmall)
                            .foregroundColor(.neutral)
                    }
                    Spacer()
                    Image(systemName: "icloud.fill")
                        .foregroundColor(.focusPrimary)
                }
            } header: {
                Text("Data Storage")
            } footer: {
                Text("Your data never leaves your device except for partner sharing, which uses end-to-end encrypted iCloud sync.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPermissionsSheet) {
            PermissionsReviewSheet()
        }
        .onChange(of: shareUsageWithPartner) { _, _ in
            savePreferences()
        }
        .onChange(of: shareDetailedApps) { _, _ in
            savePreferences()
        }
        .onChange(of: allowAnalytics) { _, _ in
            savePreferences()
        }
    }

    private func savePreferences() {
        persistence.updatePrivacySettings(
            PrivacySettings(
                shareUsageWithPartner: shareUsageWithPartner,
                shareDetailedApps: shareDetailedApps,
                allowAnalytics: allowAnalytics
            )
        )
    }
}

// MARK: - Privacy Toggle Row

struct PrivacyToggleRow: View {
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

// MARK: - Partner Visibility Row

struct PartnerVisibilityRow: View {
    let title: String
    let isVisible: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.bodyMedium)
                .foregroundColor(isVisible ? .primary : .neutral)

            Spacer()

            Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
                .foregroundColor(isVisible ? .success : .neutral)
        }
    }
}

// MARK: - Permissions Review Sheet

struct PermissionsReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var screenTimeService = ScreenTimeService.shared

    var body: some View {
        NavigationStack {
            List {
                PermissionRow(
                    icon: "hourglass",
                    title: "Screen Time",
                    status: screenTimeService.authorizationStatus == .approved ? .granted : .notGranted,
                    description: "Required to monitor and limit app usage"
                )

                PermissionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    status: .granted, // Would check actual status
                    description: "For reminders and partner alerts"
                )

                PermissionRow(
                    icon: "icloud.fill",
                    title: "iCloud",
                    status: .granted, // Would check actual status
                    description: "For partner data sync"
                )
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Permissions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Permission Row

struct PermissionRow: View {
    let icon: String
    let title: String
    let status: PermissionStatus
    let description: String

    enum PermissionStatus {
        case granted, notGranted, restricted

        var color: Color {
            switch self {
            case .granted: return .success
            case .notGranted: return .warning
            case .restricted: return .danger
            }
        }

        var icon: String {
            switch self {
            case .granted: return "checkmark.circle.fill"
            case .notGranted: return "exclamationmark.circle.fill"
            case .restricted: return "xmark.circle.fill"
            }
        }

        var label: String {
            switch self {
            case .granted: return "Granted"
            case .notGranted: return "Not Granted"
            case .restricted: return "Restricted"
            }
        }
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.focusPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.bodyMedium)

                Text(description)
                    .font(.labelSmall)
                    .foregroundColor(.neutral)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                Text(status.label)
                    .font(.labelSmall)
                    .foregroundColor(status.color)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Privacy Settings Model

struct PrivacySettings: Codable {
    var shareUsageWithPartner: Bool
    var shareDetailedApps: Bool
    var allowAnalytics: Bool

    static var `default`: PrivacySettings {
        PrivacySettings(
            shareUsageWithPartner: true,
            shareDetailedApps: false,
            allowAnalytics: true
        )
    }
}

#Preview {
    NavigationStack {
        PrivacySettingsView()
            .environmentObject(PersistenceService.shared)
    }
}
