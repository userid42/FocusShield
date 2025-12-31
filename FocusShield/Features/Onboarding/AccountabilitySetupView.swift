import SwiftUI

struct AccountabilitySetupView: View {
    @Binding var partnerName: String
    @Binding var partnerContact: String
    let onContinue: () -> Void
    let onSkip: () -> Void
    let onBack: () -> Void

    @State private var showContactOptions = false

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
                                .stroke(Color.neutral.opacity(0.2), lineWidth: 1)
                        )
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
                                .stroke(Color.neutral.opacity(0.2), lineWidth: 1)
                        )
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
                PrimaryButton(title: "Send Invitation", action: onContinue)
            } else {
                PrimaryButton(title: "Continue", action: onContinue)
                    .disabled(partnerName.isEmpty != partnerContact.isEmpty) // Both or neither
            }

            Button("Skip for now", action: onSkip)
                .font(.labelLarge)
                .foregroundColor(.neutral)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.lg)
        .animation(.smooth, value: partnerName.isEmpty)
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
