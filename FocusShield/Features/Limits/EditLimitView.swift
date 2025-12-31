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
        if let appData = limit.appTokensData,
           let apps = try? PropertyListDecoder().decode(Set<ApplicationToken>.self, from: appData) {
            selectedApps.applicationTokens = apps
        }

        // Load saved category tokens
        if let categoryData = limit.categoryTokensData,
           let categories = try? PropertyListDecoder().decode(Set<ActivityCategoryToken>.self, from: categoryData) {
            selectedApps.categoryTokens = categories
        }

        // Load saved web domain tokens
        if let webDomainData = limit.webDomainTokensData,
           let domains = try? PropertyListDecoder().decode(Set<WebDomainToken>.self, from: webDomainData) {
            selectedApps.webDomainTokens = domains
        }
    }

    private func saveLimit() {
        // Validate input
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, hasSelection else { return }

        // Encode the selection
        let appTokensData = try? PropertyListEncoder().encode(selectedApps.applicationTokens)
        let categoryTokensData = try? PropertyListEncoder().encode(selectedApps.categoryTokens)
        let webDomainTokensData = try? PropertyListEncoder().encode(selectedApps.webDomainTokens)

        var newLimit = limit ?? AppLimit()
        newLimit.name = trimmedName
        newLimit.dailyMinutes = max(5, min(480, dailyMinutes))  // Clamp to valid range
        newLimit.weekendMinutes = hasWeekendOverride ? max(5, min(480, weekendMinutes)) : nil
        newLimit.isActive = isActive
        newLimit.appTokensData = appTokensData
        newLimit.categoryTokensData = categoryTokensData
        newLimit.webDomainTokensData = webDomainTokensData
        newLimit.lastModified = Date()

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
