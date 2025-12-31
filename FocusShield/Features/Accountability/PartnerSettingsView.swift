import SwiftUI

struct PartnerSettingsView: View {
    @Binding var partner: AccountabilityPartner

    var body: some View {
        Form {
            Section {
                ToggleRow(
                    title: "Include app names",
                    isOn: Binding(
                        get: { partner.sharingPreferences.includeAppNames },
                        set: { partner.sharingPreferences.includeAppNames = $0 }
                    ),
                    subtitle: "Share which apps triggered notifications"
                )

                ToggleRow(
                    title: "Include time spent",
                    isOn: Binding(
                        get: { partner.sharingPreferences.includeTimeSpent },
                        set: { partner.sharingPreferences.includeTimeSpent = $0 }
                    ),
                    subtitle: "Share how long you used each app"
                )

                ToggleRow(
                    title: "Daily success notifications",
                    isOn: Binding(
                        get: { partner.sharingPreferences.notifyOnDailySuccess },
                        set: { partner.sharingPreferences.notifyOnDailySuccess = $0 }
                    ),
                    subtitle: "Notify when you stay within limits"
                )
            } header: {
                Text("Sharing")
            }

            Section {
                Toggle("Enable Quiet Hours", isOn: Binding(
                    get: { partner.quietHours?.isEnabled ?? false },
                    set: { enabled in
                        if partner.quietHours == nil {
                            partner.quietHours = QuietHours()
                        }
                        partner.quietHours?.isEnabled = enabled
                    }
                ))

                if partner.quietHours?.isEnabled == true {
                    HStack {
                        Text("From")
                        Spacer()
                        Text(formatHour(partner.quietHours?.startHour ?? 22))
                            .foregroundColor(.neutral)
                    }

                    HStack {
                        Text("Until")
                        Spacer()
                        Text(formatHour(partner.quietHours?.endHour ?? 8))
                            .foregroundColor(.neutral)
                    }
                }
            } header: {
                Text("Quiet Hours")
            } footer: {
                Text("Notifications won't be sent during quiet hours.")
            }
        }
        .navigationTitle("Partner Settings")
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        return "\(displayHour):00 \(period)"
    }
}

#Preview {
    NavigationStack {
        PartnerSettingsView(
            partner: .constant(AccountabilityPartner(
                name: "Sarah",
                contactMethod: .email(address: "sarah@example.com"),
                status: .active
            ))
        )
    }
}
