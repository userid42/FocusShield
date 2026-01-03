import SwiftUI
import FamilyControls

struct EditLimitView: View {
    let limit: AppLimit?
    let onSave: (AppLimit) -> Void

    @State private var name: String = ""
    @State private var dailyMinutes: Int = 30
    @State private var weekendMinutes: Int = 30
    @State private var hasWeekendOverride: Bool = false
    @State private var isActive: Bool = true
    @State private var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @State private var showingPicker = false

    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool {
        limit != nil
    }

    private var hasSelection: Bool {
        !selectedApps.applicationTokens.isEmpty || !selectedApps.categoryTokens.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Name
                Section {
                    TextField("Limit name", text: $name)
                        .accessibilityLabel("Limit name")
                        .accessibilityHint("Enter a name for this app limit")
                } header: {
                    Text("Name")
                }

                // Apps
                Section {
                    Button {
                        showingPicker = true
                    } label: {
                        HStack {
                            Text(hasSelection ? "Edit Selection" : "Select Apps")
                            Spacer()
                            if hasSelection {
                                Text("\(selectedApps.applicationTokens.count + selectedApps.categoryTokens.count) selected")
                                    .foregroundColor(.neutral)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.neutral)
                        }
                    }
                    .foregroundColor(.primary)
                    .accessibilityLabel(hasSelection ? "Edit selected apps, \(selectedApps.applicationTokens.count + selectedApps.categoryTokens.count) apps selected" : "Select apps to limit")
                    .accessibilityHint("Opens app picker")
                } header: {
                    Text("Apps to Limit")
                }

                // Daily limit
                Section {
                    Stepper("\(dailyMinutes) minutes", value: $dailyMinutes, in: 5...480, step: 5)

                    // Quick presets
                    HStack(spacing: Spacing.sm) {
                        ForEach([15, 30, 60, 120], id: \.self) { minutes in
                            Button {
                                dailyMinutes = minutes
                            } label: {
                                Text("\(minutes)m")
                                    .font(.labelMedium)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(dailyMinutes == minutes ? Color.focusPrimary : Color.neutral.opacity(0.1))
                                    .foregroundColor(dailyMinutes == minutes ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .accessibilityLabel("\(minutes) minutes preset")
                            .accessibilityAddTraits(dailyMinutes == minutes ? .isSelected : [])
                        }
                    }
                } header: {
                    Text("Daily Limit")
                }

                // Weekend override
                Section {
                    Toggle("Different limit on weekends", isOn: $hasWeekendOverride)

                    if hasWeekendOverride {
                        Stepper("\(weekendMinutes) minutes", value: $weekendMinutes, in: 5...480, step: 5)
                    }
                } header: {
                    Text("Weekend")
                }

                // Active
                Section {
                    Toggle("Limit Active", isOn: $isActive)
                } footer: {
                    Text("Inactive limits won't block apps or count usage.")
                }
            }
            .navigationTitle(isEditing ? "Edit Limit" : "New Limit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveLimit()
                    }
                    .disabled(name.isEmpty || !hasSelection)
                    .accessibilityHint(name.isEmpty ? "Enter a name to save" : !hasSelection ? "Select apps to save" : "Save limit")
                }
            }
            .familyActivityPicker(
                isPresented: $showingPicker,
                selection: $selectedApps
            )
            .onAppear {
                loadExistingLimit()
            }
        }
    }

    private func loadExistingLimit() {
        guard let limit = limit else { return }

        name = limit.name
        dailyMinutes = limit.dailyMinutes
        isActive = limit.isActive

        if let weekendMins = limit.weekendMinutes {
            hasWeekendOverride = true
            weekendMinutes = weekendMins
        }

        // Load saved app tokens
        if let appData = limit.appTokensData {
            do {
                let apps = try PropertyListDecoder().decode(Set<ApplicationToken>.self, from: appData)
                selectedApps.applicationTokens = apps
            } catch {
                LoggingService.shared.error("Failed to decode app tokens for limit '\(limit.name)'", error: error)
            }
        }

        // Load saved category tokens
        if let categoryData = limit.categoryTokensData {
            do {
                let categories = try PropertyListDecoder().decode(Set<ActivityCategoryToken>.self, from: categoryData)
                selectedApps.categoryTokens = categories
            } catch {
                LoggingService.shared.error("Failed to decode category tokens for limit '\(limit.name)'", error: error)
            }
        }

        // Load saved web domain tokens
        if let webDomainData = limit.webDomainTokensData {
            do {
                let domains = try PropertyListDecoder().decode(Set<WebDomainToken>.self, from: webDomainData)
                selectedApps.webDomainTokens = domains
            } catch {
                LoggingService.shared.error("Failed to decode web domain tokens for limit '\(limit.name)'", error: error)
            }
        }
    }

    private func saveLimit() {
        // Validate input
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, hasSelection else {
            LoggingService.shared.warning("Attempted to save limit with invalid data")
            return
        }

        // Encode the selection
        var appTokensData: Data?
        var categoryTokensData: Data?
        var webDomainTokensData: Data?

        do {
            appTokensData = try PropertyListEncoder().encode(selectedApps.applicationTokens)
            categoryTokensData = try PropertyListEncoder().encode(selectedApps.categoryTokens)
            webDomainTokensData = try PropertyListEncoder().encode(selectedApps.webDomainTokens)
        } catch {
            LoggingService.shared.error("Failed to encode app selection for limit '\(trimmedName)'", error: error)
            // Continue with nil data - at least save the limit metadata
        }

        var newLimit = limit ?? AppLimit()
        newLimit.name = trimmedName
        newLimit.dailyMinutes = max(5, min(480, dailyMinutes))  // Clamp to valid range
        newLimit.weekendMinutes = hasWeekendOverride ? max(5, min(480, weekendMinutes)) : nil
        newLimit.isActive = isActive
        newLimit.appTokensData = appTokensData
        newLimit.categoryTokensData = categoryTokensData
        newLimit.webDomainTokensData = webDomainTokensData
        newLimit.lastModified = Date()

        LoggingService.shared.info("Saved limit '\(trimmedName)' with \(dailyMinutes) minutes daily")
        HapticPattern.success()
        onSave(newLimit)
        dismiss()
    }
}

// MARK: - AppLimit Extension for init

extension AppLimit {
    init() {
        self.init(
            id: UUID(),
            name: "",
            appTokensData: nil,
            categoryTokensData: nil,
            webDomainTokensData: nil,
            dailyMinutes: 30,
            weekendMinutes: nil,
            isActive: true,
            createdAt: Date(),
            lastModified: Date()
        )
    }
}

#Preview {
    EditLimitView(limit: nil) { _ in }
}
