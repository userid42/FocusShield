import SwiftUI

struct AccountabilitySetupView: View {
    @Binding var partnerName: String
    @Binding var partnerContact: String
    let onContinue: () -> Void
    let onSkip: () -> Void
    let onBack: () -> Void

    @State private var showContactOptions = false
    @State private var nameError: String?
    @State private var contactError: String?
    @State private var hasAttemptedSubmit = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Back button
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.labelLarge)
                        .foregroundColor(.focusPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)

                // Header
                VStack(spacing: Spacing.sm) {
                    Text("Add an accountability partner")
                        .font(.displayMedium)
                        .multilineTextAlignment(.center)

                    Text("Optional but powerful")
                        .font(.bodyMedium)
                        .foregroundColor(.neutral)
                }
                .padding(.horizontal, Spacing.md)

                // Explanation card
                FocusCard {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.focusPrimary)
                            Text("How it works")
                                .font(.headlineMedium)
                        }

                        Text("When you exceed limits or disable accountability, your partner receives a brief notification. No surveillance - just awareness.")
                            .font(.bodySmall)
                            .foregroundColor(.neutral)
                    }
                }
                .padding(.horizontal, Spacing.md)

                // Name input
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Partner's name")
                        .font(.labelMedium)
                        .foregroundColor(.neutral)

                    TextField("e.g., Sarah", text: $partnerName)
                        .textFieldStyle(.plain)
                        .padding(Spacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(nameError != nil ? Color.danger : Color.neutral.opacity(0.2), lineWidth: 1)
                        )
                        .accessibilityLabel("Partner's name")
                        .accessibilityHint("Enter your accountability partner's first name")
                        .onChange(of: partnerName) { _, _ in
                            if hasAttemptedSubmit {
                                validateName()
                            }
                        }

                    if let error = nameError {
                        Text(error)
                            .font(.labelSmall)
                            .foregroundColor(.danger)
                            .accessibilityLabel("Error: \(error)")
                    }
                }
                .padding(.horizontal, Spacing.md)

                // Contact input
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Email or phone number")
                        .font(.labelMedium)
                        .foregroundColor(.neutral)

                    TextField("email@example.com or +1234567890", text: $partnerContact)
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(Spacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(contactError != nil ? Color.danger : Color.neutral.opacity(0.2), lineWidth: 1)
                        )
                        .accessibilityLabel("Partner's email or phone number")
                        .accessibilityHint("Enter an email address or phone number to contact your partner")
                        .onChange(of: partnerContact) { _, _ in
                            if hasAttemptedSubmit {
                                validateContact()
                            }
                        }

                    if let error = contactError {
                        Text(error)
                            .font(.labelSmall)
                            .foregroundColor(.danger)
                            .accessibilityLabel("Error: \(error)")
                    }
                }
                .padding(.horizontal, Spacing.md)

                // Transparency note
                if !partnerName.isEmpty {
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.focusPrimary)

                        Text("Your partner will be notified that you've added them and asked to confirm. They can decline.")
                            .font(.labelMedium)
                            .foregroundColor(.neutral)
                    }
                    .padding(Spacing.md)
                    .background(Color.focusPrimary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    .padding(.horizontal, Spacing.md)
                    .transition(.fadeAndSlide)
                }

                Spacer(minLength: Spacing.xxl)
            }
        }

        // Bottom buttons
        VStack(spacing: Spacing.sm) {
            if !partnerName.isEmpty && !partnerContact.isEmpty {
                PrimaryButton(
                    title: "Send Invitation",
                    action: handleContinue,
                    accessibilityHint: "Send invitation to \(partnerName)"
                )
            } else {
                PrimaryButton(
                    title: "Continue",
                    action: handleContinue,
                    isDisabled: shouldDisableContinue,
                    accessibilityHint: shouldDisableContinue ? "Fill in both name and contact to continue, or skip" : "Continue setup"
                )
            }

            Button("Skip for now", action: onSkip)
                .font(.labelLarge)
                .foregroundColor(.neutral)
                .accessibilityHint("Skip adding an accountability partner")
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.lg)
        .animation(.smooth, value: partnerName.isEmpty)
    }

    // MARK: - Helpers

    private var shouldDisableContinue: Bool {
        // Disable if only one field is filled (must be both or neither)
        let hasName = !partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasContact = !partnerContact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasName != hasContact
    }

    private func handleContinue() {
        hasAttemptedSubmit = true

        // Validate both fields if they're filled
        if !partnerName.isEmpty || !partnerContact.isEmpty {
            validateName()
            validateContact()

            // Only continue if both are valid
            if nameError == nil && contactError == nil {
                onContinue()
            } else {
                // Provide haptic feedback for validation errors
                HapticPattern.error()
            }
        } else {
            // Both empty, continue without partner
            onContinue()
        }
    }

    private func validateName() {
        let trimmed = partnerName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty && !partnerContact.isEmpty {
            nameError = "Partner's name is required"
        } else if !trimmed.isEmpty && !Validation.isValidName(trimmed) {
            nameError = "Please enter a valid name"
        } else {
            nameError = nil
        }
    }

    private func validateContact() {
        let trimmed = partnerContact.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty && !partnerName.isEmpty {
            contactError = "Contact information is required"
        } else if !trimmed.isEmpty {
            let result = Validation.validateContact(trimmed, type: .auto)
            contactError = result.errorMessage
        } else {
            contactError = nil
        }
    }
}

#Preview {
    AccountabilitySetupView(
        partnerName: .constant(""),
        partnerContact: .constant(""),
        onContinue: {},
        onSkip: {},
        onBack: {}
    )
}
