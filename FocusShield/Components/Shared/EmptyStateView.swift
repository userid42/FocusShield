import SwiftUI

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var iconColor: Color = .neutral

    @State private var iconScale: CGFloat = 0.8
    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Icon with subtle gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [iconColor.opacity(0.15), iconColor.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
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
            .opacity(contentOpacity)

            // Action button
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.md)
                    .opacity(contentOpacity)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
        .accessibilityHint(actionTitle.map { "Double tap to \($0.lowercased())" } ?? "")
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                contentOpacity = 1.0
            }
        }
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
            action: onAddLimit,
            iconColor: .focusPrimary
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
            action: onAddPartner,
            iconColor: .success
        )
    }
}

// MARK: - No Insights Empty State

struct NoInsightsEmptyState: View {
    var body: some View {
        EmptyStateView(
            icon: "lightbulb",
            title: "Insights coming soon",
            message: "Use the app for a few days and we'll show you patterns and suggestions.",
            iconColor: .warning
        )
    }
}

// MARK: - No Events Empty State

struct NoEventsEmptyState: View {
    var body: some View {
        EmptyStateView(
            icon: "checkmark.shield",
            title: "All clear",
            message: "Your integrity log is empty. Events will appear here as they happen.",
            iconColor: .success
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        NoLimitsEmptyState(onAddLimit: {})
    }
    .background(LinearGradient.backgroundGradient)
}
