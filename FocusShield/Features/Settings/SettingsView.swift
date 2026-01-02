import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var persistence: PersistenceService
    @State private var showingResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                // Commitment Mode Section
                Section {
                    NavigationLink {
                        CommitmentModeView()
                    } label: {
                        SettingsRow(
                            icon: "lock.shield.fill",
                            iconColor: .focusPrimary,
                            title: "Commitment Mode",
                            value: persistence.user?.commitmentMode.rawValue ?? "Standard"
                        )
                    }
                } header: {
                    Text("Protection Level")
                }

                // Notifications Section
                Section {
                    NavigationLink {
                        NotificationPrefsView()
                    } label: {
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: .warning,
                            title: "Notifications",
                            value: nil
                        )
                    }

                    NavigationLink {
                        ScheduleView()
                    } label: {
                        SettingsRow(
                            icon: "clock.fill",
                            iconColor: .focusSecondary,
                            title: "Focus Schedule",
                            value: nil
                        )
                    }
                } header: {
                    Text("Preferences")
                }

                // Accountability Section
                Section {
                    NavigationLink {
                        AccountabilityView()
                    } label: {
                        SettingsRow(
                            icon: "person.2.fill",
                            iconColor: .success,
                            title: "Accountability Partner",
                            value: persistence.partner?.name
                        )
                    }

                    NavigationLink {
                        IntegrityLogView()
                    } label: {
                        SettingsRow(
                            icon: "list.bullet.clipboard.fill",
                            iconColor: .neutral,
                            title: "Integrity Log",
                            value: nil
                        )
                    }
                } header: {
                    Text("Accountability")
                }

                // Privacy Section
                Section {
                    NavigationLink {
                        PrivacySettingsView()
                    } label: {
                        SettingsRow(
                            icon: "hand.raised.fill",
                            iconColor: .danger,
                            title: "Privacy",
                            value: nil
                        )
                    }

                    NavigationLink {
                        DataExportView()
                    } label: {
                        SettingsRow(
                            icon: "square.and.arrow.up.fill",
                            iconColor: .focusPrimary,
                            title: "Export Data",
                            value: nil
                        )
                    }
                } header: {
                    Text("Privacy & Data")
                }

                // About Section
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        SettingsRow(
                            icon: "info.circle.fill",
                            iconColor: .focusPrimary,
                            title: "About FocusShield",
                            value: nil
                        )
                    }

                    if let supportURL = URL(string: "https://focusshield.app/support") {
                        Link(destination: supportURL) {
                            SettingsRow(
                                icon: "questionmark.circle.fill",
                                iconColor: .neutral,
                                title: "Help & Support",
                                value: nil,
                                showChevron: false
                            )
                        }
                        .accessibilityHint("Opens in Safari")
                    }
                } header: {
                    Text("About")
                }

                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Data")
                        }
                    }
                } footer: {
                    Text("This will delete all your progress, limits, and settings. This action cannot be undone.")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    persistence.resetAllData()
                }
            } message: {
                Text("This will permanently delete all your data including progress, achievements, and settings.")
            }
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String?
    var showChevron: Bool = true

    private var accessibilityLabel: String {
        if let value = value {
            return "\(title), \(value)"
        }
        return title
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .accessibilityHidden(true)

            Text(title)
                .font(.bodyMedium)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.labelMedium)
                    .foregroundColor(.neutral)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.neutral.opacity(0.5))
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    SettingsView()
        .environmentObject(PersistenceService.shared)
}
