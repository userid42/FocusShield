import SwiftUI

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.neutral.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.neutral)
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

            // Action button
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.md)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - No Limits Empty State

struct NoLimitsEmptyState: View {
    let onAddLimit: () -> Void

    var body: some View {
        EmptyStateView(
            icon: "clock.badge.plus",
            title: "No limits yet",
            message: "Add your first limit to start tracking your app usage and building better habits.",
            actionTitle: "Add Limit",
            action: onAddLimit
        )
    }
}

// MARK: - No Partner Empty State

struct NoPartnerEmptyState: View {
    let onAddPartner: () -> Void

    var body: some View {
        EmptyStateView(
            icon: "person.badge.plus",
            title: "No accountability partner",
            message: "Adding a partner makes you 65% more likely to stick to your goals.",
            actionTitle: "Add Partner",
            action: onAddPartner
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        EmptyStateView(
            icon: "tray",
            title: "No events yet",
            message: "Your integrity events will appear here as they happen."
        )
    }
    .background(Color.backgroundStart)
}
