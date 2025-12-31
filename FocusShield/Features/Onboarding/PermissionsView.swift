import SwiftUI
import FamilyControls

struct PermissionsView: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    @EnvironmentObject var screenTimeService: ScreenTimeService
    @State private var isAuthorizing = false
    @State private var authorizationError: String?
    @State private var isAuthorized = false

    var body: some View {
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

            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.focusPrimary.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: isAuthorized ? "checkmark.shield.fill" : "shield.checkered")
                    .font(.system(size: 40))
                    .foregroundColor(isAuthorized ? .success : .focusPrimary)
            }

            // Explanation
            VStack(spacing: Spacing.md) {
                Text(isAuthorized ? "You're all set!" : "One permission needed")
                    .font(.displayMedium)

                Text(isAuthorized
                     ? "Screen Time access is enabled. FocusShield can now help you manage your app usage."
                     : "We use Apple's Screen Time to shield apps you choose."
                )
                    .font(.bodyLarge)
                    .foregroundColor(.neutral)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)

                // Transparency note
                if !isAuthorized {
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.warning)

                        Text("You can turn this off in Settings - if you do, your accountability partner will be notified.")
                            .font(.bodySmall)
                            .foregroundColor(.neutral)
                    }
                    .padding(Spacing.md)
                    .background(Color.warning.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    .padding(.horizontal, Spacing.md)
                }
            }

            Spacer()

            // Error display
            if let error = authorizationError {
                InlineError(message: error)
                    .padding(.horizontal, Spacing.md)
            }

            // Authorize button
            if isAuthorized {
                PrimaryButton(title: "Continue", action: onContinue)
                    .padding(.horizontal, Spacing.md)
            } else {
                PrimaryButton(
                    title: "Enable Screen Time Access",
                    action: requestAuthorization,
                    isLoading: isAuthorizing
                )
                .padding(.horizontal, Spacing.md)
            }

            // Skip option (for testing)
            if !isAuthorized {
                Button("Continue without (limited features)") {
                    onContinue()
                }
                .font(.labelMedium)
                .foregroundColor(.neutral)
            }

            Spacer()
                .frame(height: Spacing.lg)
        }
        .onAppear {
            checkAuthorization()
        }
    }

    private func checkAuthorization() {
        isAuthorized = screenTimeService.isAuthorized
    }

    private func requestAuthorization() {
        isAuthorizing = true
        authorizationError = nil

        Task {
            do {
                try await screenTimeService.requestAuthorization()
                isAuthorized = screenTimeService.isAuthorized

                if isAuthorized {
                    HapticPattern.success()
                }
            } catch {
                authorizationError = "Authorization failed. Please try again or enable in Settings."
                HapticPattern.error()
            }
            isAuthorizing = false
        }
    }
}

#Preview {
    PermissionsView(
        onContinue: {},
        onBack: {}
    )
    .environmentObject(ScreenTimeService.shared)
}
