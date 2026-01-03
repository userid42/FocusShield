import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var persistence: PersistenceService
    @State private var showingResetAlert = false
    @State private var showingProInfo = false

    var body: some View {
        NavigationStack {
            List {
                // Pro Features Section (Prominent)
                Section {
                    ProFeatureToggleRow(
                        isEnabled: persistence.appSettings.proFeaturesEnabled,
                        onToggle: { enabled in
                            HapticPattern.selection()
                            persistence.updateProFeaturesEnabled(enabled)
                        },
                        onInfoTap: { showingProInfo = true }
                    )
                } header: {
                    Label("Pro Features", systemImage: "star.fill")
                        .foregroundColor(.warning)
                } footer: {
                    Text(persistence.appSettings.proFeaturesEnabled
                         ? "All Pro features are enabled"
                         : "Enable to unlock unlimited limits, advanced analytics, and more")
                }

                // Appearance Section
                Section {
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        SettingsRow(
                            icon: persistence.appSettings.appearanceMode.icon,
                            iconColor: .focusSecondary,
                            title: "Appearance",
                            value: persistence.appSettings.appearanceMode.rawValue
                        )
                    }

                    Toggle(isOn: Binding(
                        get: { persistence.appSettings.hapticsEnabled },
                        set: { persistence.updateHapticsEnabled($0) }
                    )) {
                        SettingsRow(
                            icon: "hand.tap.fill",
                            iconColor: .focusPrimary,
                            title: "Haptic Feedback",
                            value: nil,
                            showChevron: false
                        )
                    }
                    .tint(.focusPrimary)
                } header: {
                    Text("Appearance & Feedback")
                }

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

                // Preferences Section
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
            .sheet(isPresented: $showingProInfo) {
                ProFeaturesInfoView()
            }
        }
    }
}

// MARK: - Pro Feature Toggle Row

struct ProFeatureToggleRow: View {
    let isEnabled: Bool
    let onToggle: (Bool) -> Void
    let onInfoTap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon with gradient background
            ZStack {
                LinearGradient(
                    colors: [.warning, .warning.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 32, height: 32)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Pro Features")
                    .font(.bodyMedium)
                    .fontWeight(.medium)

                Text(isEnabled ? "Enabled" : "Disabled")
                    .font(.labelSmall)
                    .foregroundColor(isEnabled ? .success : .neutral)
            }

            Spacer()

            Button {
                onInfoTap()
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 18))
                    .foregroundColor(.focusPrimary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Learn more about Pro features")

            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { onToggle($0) }
            ))
            .labelsHidden()
            .tint(.warning)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pro Features, \(isEnabled ? "enabled" : "disabled")")
        .accessibilityHint("Double tap to toggle Pro features")
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

// MARK: - Appearance Settings View

struct AppearanceSettingsView: View {
    @EnvironmentObject var persistence: PersistenceService

    var body: some View {
        List {
            Section {
                ForEach(AppearanceMode.allCases) { mode in
                    Button {
                        HapticPattern.selection()
                        withAnimation(.smooth) {
                            persistence.updateAppearanceMode(mode)
                        }
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 20))
                                .foregroundColor(.focusPrimary)
                                .frame(width: 32, height: 32)
                                .background(Color.focusPrimary.opacity(0.1))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.rawValue)
                                    .font(.bodyMedium)
                                    .foregroundColor(.primary)

                                Text(mode.description)
                                    .font(.labelSmall)
                                    .foregroundColor(.neutral)
                            }

                            Spacer()

                            if persistence.appSettings.appearanceMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.focusPrimary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(mode.rawValue), \(mode.description)")
                    .accessibilityAddTraits(persistence.appSettings.appearanceMode == mode ? .isSelected : [])
                }
            } header: {
                Text("Theme")
            } footer: {
                Text("Choose how FocusShield looks on your device")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Pro Features Info View

struct ProFeaturesInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var persistence: PersistenceService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.warning, .warning.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: "crown.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        .shadow(color: .warning.opacity(0.3), radius: 12, y: 4)

                        Text("FocusShield Pro")
                            .font(.headlineLarge)

                        Text("Unlock the full potential of FocusShield")
                            .font(.bodyMedium)
                            .foregroundColor(.neutral)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Spacing.xl)

                    // Features List
                    VStack(spacing: Spacing.sm) {
                        ForEach(ProFeature.allCases) { feature in
                            ProFeatureRow(feature: feature)
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    // Toggle
                    VStack(spacing: Spacing.sm) {
                        Toggle(isOn: Binding(
                            get: { persistence.appSettings.proFeaturesEnabled },
                            set: { enabled in
                                HapticPattern.success()
                                persistence.updateProFeaturesEnabled(enabled)
                            }
                        )) {
                            Text(persistence.appSettings.proFeaturesEnabled ? "Pro Enabled" : "Enable Pro")
                                .font(.labelLarge)
                                .fontWeight(.semibold)
                        }
                        .toggleStyle(ProToggleStyle())
                        .padding(.horizontal, Spacing.md)

                        Text("Toggle to enable or disable Pro features")
                            .font(.labelSmall)
                            .foregroundColor(.neutral)
                    }
                    .padding(.vertical, Spacing.lg)

                    Spacer(minLength: Spacing.xxl)
                }
            }
            .background(LinearGradient.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Pro Feature Row

struct ProFeatureRow: View {
    let feature: ProFeature

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: feature.icon)
                .font(.system(size: 18))
                .foregroundColor(.warning)
                .frame(width: 36, height: 36)
                .background(Color.warning.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.bodyMedium)
                    .fontWeight(.medium)

                Text(feature.description)
                    .font(.labelSmall)
                    .foregroundColor(.neutral)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(Spacing.sm)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Pro Toggle Style

struct ProToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                Spacer()
                ZStack {
                    Capsule()
                        .fill(configuration.isOn
                              ? LinearGradient(colors: [.warning, .warning.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                              : LinearGradient(colors: [.neutral.opacity(0.3), .neutral.opacity(0.2)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 51, height: 31)

                    Circle()
                        .fill(.white)
                        .frame(width: 27, height: 27)
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.spring(response: 0.3), value: configuration.isOn)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environmentObject(PersistenceService.shared)
}
