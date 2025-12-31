import SwiftUI

// MARK: - Goal Option Card

struct GoalOptionCard: View {
    let goal: UserGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticPattern.selection()
            onTap()
        }) {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.focusPrimary.opacity(0.1) : Color.neutral.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: goal.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .focusPrimary : .neutral)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.rawValue)
                        .font(.headlineMedium)
                        .foregroundColor(.primary)

                    Text(goal.description)
                        .font(.bodySmall)
                        .foregroundColor(.neutral)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.focusPrimary)
                        .font(.system(size: 24))
                }
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .stroke(isSelected ? Color.focusPrimary : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(isSelected ? 0.08 : 0.04), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        GoalOptionCard(
            goal: .stopDoomscrolling,
            isSelected: true
        ) {}

        GoalOptionCard(
            goal: .bePresent,
            isSelected: false
        ) {}

        GoalOptionCard(
            goal: .focusWork,
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color.backgroundStart)
}
