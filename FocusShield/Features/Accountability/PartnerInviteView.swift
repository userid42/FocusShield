import SwiftUI

struct PartnerInviteView: View {
    @State private var name: String = ""
    @State private var contact: String = ""
    @State private var isSending = false
    @State private var showSuccess = false

    @EnvironmentObject var persistence: PersistenceService
    @Environment(\.dismiss) private var dismiss

    private var isValid: Bool {
        !name.isEmpty && !contact.isEmpty
    }

    var body: some View {
        NavigationStack {
            if showSuccess {
                InviteSentView(partnerName: name) {
                    dismiss()
                }
            } else {
                Form {
                    Section {
                        TextField("Partner's name", text: $name)
                    } header: {
                        Text("Name")
                    }

                    Section {
                        TextField("Email or phone number", text: $contact)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    } header: {
                        Text("Contact")
                    } footer: {
                        Text("We'll send them an invitation to be your accountability partner.")
                    }

                    Section {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("What happens next?")
                                .font(.headlineMedium)

                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                BulletPoint(text: "They'll receive an invitation message")
                                BulletPoint(text: "They can accept or decline")
                                BulletPoint(text: "Once accepted, they'll be notified of your activity")
                            }
                        }
                    }
                }
                .navigationTitle("Invite Partner")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Send") {
                            sendInvite()
                        }
                        .disabled(!isValid || isSending)
                    }
                }
            }
        }
    }

    private func sendInvite() {
        isSending = true

        let contactMethod: ContactMethod = contact.contains("@")
            ? .email(address: contact)
            : .sms(phoneNumber: contact)

        let partner = AccountabilityPartner(
            name: name,
            contactMethod: contactMethod,
            status: .pending
        )

        // Save partner
        persistence.savePartner(partner)

        // Simulate sending
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSending = false
            showSuccess = true
            HapticPattern.success()
        }
    }
}

// MARK: - Bullet Point

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Circle()
                .fill(Color.focusPrimary)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(.bodySmall)
                .foregroundColor(.neutral)
        }
    }
}

// MARK: - Invite Sent View

struct InviteSentView: View {
    let partnerName: String
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.success.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "paperplane.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.success)
            }

            VStack(spacing: Spacing.sm) {
                Text("Invitation Sent!")
                    .font(.headlineLarge)

                Text("We've sent an invitation to \(partnerName). You'll be notified when they respond.")
                    .font(.bodyMedium)
                    .foregroundColor(.neutral)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }

            Spacer()

            PrimaryButton(title: "Done", action: onDone)
                .padding(.horizontal, Spacing.md)

            Spacer()
                .frame(height: Spacing.lg)
        }
    }
}

#Preview {
    PartnerInviteView()
        .environmentObject(PersistenceService.shared)
}
