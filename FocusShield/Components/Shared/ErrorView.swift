import SwiftUI

// MARK: - Error View

struct ErrorView: View {
    let title: String
    let message: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.danger.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.danger)
            }

            // Text
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.headlineLarge)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.bodyMedium)
                    .foregroundColor(.neutral)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }

            // Retry button
            if let retry = retryAction {
                SecondaryButton(title: "Try Again", action: retry)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.md)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Inline Error

struct InlineError: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.danger)

            Text(message)
                .font(.bodySmall)
                .foregroundColor(.danger)
        }
        .padding(Spacing.sm)
        .background(Color.danger.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

// MARK: - Authorization Error

struct AuthorizationErrorView: View {
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.warning.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.warning)
            }

            VStack(spacing: Spacing.sm) {
                Text("Permission Required")
                    .font(.headlineLarge)

                Text("FocusShield needs Screen Time access to help you manage your app usage. Please enable it in Settings.")
                    .font(.bodyMedium)
                    .foregroundColor(.neutral)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }

            PrimaryButton(title: "Open Settings") {
                onOpenSettings()
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ErrorView(
            title: "Something went wrong",
            message: "We couldn't load your data. Please try again.",
            retryAction: {}
        )

        InlineError(message: "Please enter a valid email address")
            .padding()
    }
    .background(Color.backgroundStart)
}
