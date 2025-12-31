import SwiftUI

// MARK: - Insight Card

struct InsightCard: View {
    let insight: Insight
    var onAction: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil

    private var iconColor: Color {
        switch insight.type {
        case .pattern: return .focusPrimary
        case .improvement: return .success
        case .suggestion: return .warning
        case .celebration: return .focusSecondary
        case .warning: return .danger
        }
    }

    private var icon: String {
        insight.type.icon
    }

    private var insightTypeLabel: String {
        switch insight.type {
        case .pattern: return "Pattern insight"
        case .improvement: return "Improvement"
        case .suggestion: return "Suggestion"
        case .celebration: return "Celebration"
        case .warning: return "Warning"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(insight.message)
                    .font(.bodyMedium)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if let actionLabel = insight.actionLabel {
                    Button {
                        HapticPattern.selection()
                        onAction?()
                    } label: {
                        Text(actionLabel)
                            .font(.labelMedium)
                            .foregroundColor(.focusPrimary)
                    }
                    .accessibilityHint("Double tap to take action")
                }
            }

            Spacer()

            // Dismiss button
            if let onDismiss = onDismiss {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.neutral)
                        .padding(Spacing.xs)
                }
                .accessibilityLabel("Dismiss insight")
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(insightTypeLabel): \(insight.message)")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        InsightCard(
            insight: Insight(
                type: .pattern(day: "Sunday", time: "evening"),
                message: "Sunday nights are your hardest time. You've exceeded limits 3 Sundays in a row.",
                actionLabel: "Add evening block"
            )
        )

        InsightCard(
            insight: Insight(
                type: .improvement(metric: "mornings clear", changePercent: 40),
                message: "You've kept 40% more mornings clear this week vs last week."
            )
        )

        InsightCard(
            insight: Insight(
                type: .celebration(achievement: "7-day streak"),
                message: "You're on a 7-day streak. Your longest yet!"
            ),
            onDismiss: {}
        )
    }
    .padding()
    .background(Color.backgroundStart)
}
