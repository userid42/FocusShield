import SwiftUI

struct EmergencyAccessView: View {
    let appName: String
    let onComplete: () -> Void

    @State private var reason: String = ""
    @State private var isConfirmed = false
    @State private var showConfirmation = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                if showConfirmation {
                    // Confirmation state
                    VStack(spacing: Spacing.lg) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color.warning.opacity(0.1))
                                .frame(width: 80, height: 80)

                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.warning)
                        }

                        Text("Emergency Access Granted")
                            .font(.headlineLarge)

                        Text("Your accountability partner has been notified that you used emergency access.")
                            .font(.bodyMedium)
                            .foregroundColor(.neutral)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)

                        Spacer()

                        PrimaryButton(title: "Continue to \(appName)") {
                            onComplete()
                            dismiss()
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                } else {
                    // Warning state
                    VStack(spacing: Spacing.lg) {
                        // Warning icon
                        ZStack {
                            Circle()
                                .fill(Color.danger.opacity(0.1))
                                .frame(width: 80, height: 80)

                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.danger)
                        }
                        .padding(.top, Spacing.lg)

                        Text("Emergency Access")
                            .font(.headlineLarge)

                        Text("This will immediately notify your accountability partner that you're bypassing your limits.")
                            .font(.bodyMedium)
                            .foregroundColor(.neutral)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)

                        // Reason input
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("What's the emergency?")
                                .font(.labelMedium)
                                .foregroundColor(.neutral)

                            TextField("e.g., Urgent work message", text: $reason)
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

                        Spacer()

                        // Confirmation toggle
                        HStack(spacing: Spacing.sm) {
                            Button {
                                HapticPattern.selection()
                                isConfirmed.toggle()
                            } label: {
                                Image(systemName: isConfirmed ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 24))
                                    .foregroundColor(isConfirmed ? .focusPrimary : .neutral)
                            }

                            Text("I understand my partner will be notified")
                                .font(.bodySmall)
                                .foregroundColor(.neutral)
                        }
                        .padding(.horizontal, Spacing.md)

                        // Buttons
                        VStack(spacing: Spacing.sm) {
                            Button {
                                HapticPattern.warning()
                                showConfirmation = true

                                // Log and notify
                                PersistenceService.shared.logIntegrityEvent(
                                    .emergencyAccess,
                                    appName: appName,
                                    context: reason
                                )
                            } label: {
                                Text("Use Emergency Access")
                                    .font(.labelLarge)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Spacing.md)
                                    .background(Color.danger)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                            }
                            .disabled(!isConfirmed)
                            .opacity(isConfirmed ? 1 : 0.5)

                            Button("Never mind") {
                                dismiss()
                            }
                            .font(.labelLarge)
                            .foregroundColor(.neutral)
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                }
            }
            .padding(.bottom, Spacing.lg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !showConfirmation {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    EmergencyAccessView(appName: "Instagram", onComplete: {})
}
