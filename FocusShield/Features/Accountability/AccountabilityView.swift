import SwiftUI

struct AccountabilityView: View {
    @EnvironmentObject var persistence: PersistenceService
    @State private var showingInvite = false

    var body: some View {
        NavigationStack {
            Group {
                if let partner = persistence.partner {
                    PartnerDetailView(partner: partner)
                } else {
                    NoPartnerEmptyState {
                        showingInvite = true
                    }
                }
            }
            .navigationTitle("Accountability")
            .sheet(isPresented: $showingInvite) {
                PartnerInviteView()
            }
        }
    }
}

// MARK: - Partner Detail View

struct PartnerDetailView: View {
    let partner: AccountabilityPartner

    @EnvironmentObject var persistence: PersistenceService
    @State private var showingSettings = false
    @State private var showingRemoveConfirmation = false

    var body: some View {
        List {
            // Partner info
            Section {
                HStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.focusPrimary.opacity(0.1))
                            .frame(width: 56, height: 56)

                        Text(String(partner.name.prefix(1)))
                            .font(.headlineLarge)
                            .foregroundColor(.focusPrimary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(partner.name)
                            .font(.headlineMedium)

                        HStack(spacing: Spacing.xs) {
                            Image(systemName: partner.status.icon)
                                .font(.system(size: 12))
                            Text(partner.status.rawValue)
                                .font(.labelMedium)
                        }
                        .foregroundColor(partner.status == .active ? .success : .warning)
                    }
                }
            }

            // Contact method
            Section {
                HStack {
                    Image(systemName: partner.contactMethod.icon)
                        .foregroundColor(.focusPrimary)
                    Text(partner.contactMethod.displayValue)
                }
            } header: {
                Text("Contact")
            }

            // What they see
            Section {
                ToggleRow(
                    title: "When I exceed limits",
                    isOn: .constant(partner.sharingPreferences.notifyOnLimitExceeded),
                    isLocked: true
                )

                ToggleRow(
                    title: "Integrity events",
                    isOn: .constant(partner.sharingPreferences.notifyOnIntegrityEvents),
                    isLocked: true
                )

                ToggleRow(
                    title: "App names",
                    isOn: .constant(partner.sharingPreferences.includeAppNames)
                )
            } header: {
                Text("What They See")
            } footer: {
                Text("Core notifications cannot be disabled - that's the point!")
            }

            // Actions
            Section {
                Button("View Activity Log") {
                    // Navigate to log
                }
                .foregroundColor(.focusPrimary)

                Button("Remove Partner") {
                    showingRemoveConfirmation = true
                }
                .foregroundColor(.danger)
            }
        }
        .confirmationDialog(
            "Remove Partner?",
            isPresented: $showingRemoveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                persistence.removePartner()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your partner will be notified that you removed them. This cannot be undone.")
        }
    }
}

#Preview {
    AccountabilityView()
        .environmentObject(PersistenceService.shared)
}
