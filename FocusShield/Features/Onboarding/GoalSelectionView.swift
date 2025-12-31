import SwiftUI

struct GoalSelectionView: View {
    @Binding var selectedGoal: UserGoal?
    let onContinue: () -> Void
    let onBack: () -> Void

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

            // Header
            VStack(spacing: Spacing.sm) {
                Text("What do you want to change?")
                    .font(.displayMedium)
                    .multilineTextAlignment(.center)

                Text("This helps us personalize your experience")
                    .font(.bodyMedium)
                    .foregroundColor(.neutral)
            }
            .padding(.horizontal, Spacing.md)

            // Goal options
            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(UserGoal.allCases) { goal in
                        GoalOptionCard(
                            goal: goal,
                            isSelected: selectedGoal == goal,
                            onTap: {
                                withAnimation(.focusSpring) {
                                    selectedGoal = goal
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
            }

            Spacer()

            // Continue button
            PrimaryButton(title: "Continue", action: onContinue)
                .disabled(selectedGoal == nil)
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.lg)
        }
    }
}

#Preview {
    GoalSelectionView(
        selectedGoal: .constant(.stopDoomscrolling),
        onContinue: {},
        onBack: {}
    )
}
