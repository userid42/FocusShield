import SwiftUI

// MARK: - Error View

struct ErrorView: View {
    let title: String
    let message: String
    var retryAction: (() -> Void)? = nil

    @State private var iconScale: CGFloat = 0.8

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.danger.opacity(0.15), Color.danger.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.danger)
            }
            .scaleEffect(iconScale)
            .accessibilityHidden(true)

            // Text
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.headlineLarge)
                    .foregroundColor(.adaptiveText)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.bodyMedium)
                    .foregroundColor(.adaptiveSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(title). \(message)")
        .accessibilityHint(retryAction != nil ? "Double tap to try again" : "")
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                iconScale = 1.0
            }
        }
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

    @State private var iconScale: CGFloat = 0.8

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.warning.opacity(0.15), Color.warning.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.warning)
            }
            .scaleEffect(iconScale)
            .accessibilityHidden(true)

            VStack(spacing: Spacing.sm) {
                Text("Permission Required")
                    .font(.headlineLarge)
                    .foregroundColor(.adaptiveText)

                Text("FocusShield needs Screen Time access to help you manage your app usage. Please enable it in Settings.")
                    .font(.bodyMedium)
                    .foregroundColor(.adaptiveSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, Spacing.lg)
            }

            PrimaryButton(title: "Open Settings") {
                onOpenSettings()
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Permission Required. FocusShield needs Screen Time access.")
        .accessibilityHint("Double tap to open Settings")
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                iconScale = 1.0
            }
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
    .background(LinearGradient.backgroundGradient)
}
