import SwiftUI

struct CommitmentLevelView: View {
    @Binding var selectedMode: CommitmentMode
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
                Text("How strict?")
                    .font(.displayMedium)

                Text("You can change this anytime")
                    .font(.bodyMedium)
                    .foregroundColor(.neutral)
            }

            // Mode options
            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(CommitmentMode.allCases) { mode in
                        CommitmentCard(
                            mode: mode,
                            isSelected: selectedMode == mode,
                            onTap: {
                                withAnimation(.focusSpring) {
                                    selectedMode = mode
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
            }

            // Recommendation badge
            if selectedMode == .standard {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.warning)
                    Text("Recommended for most users")
                        .font(.labelMedium)
                        .foregroundColor(.neutral)
                }
                .padding(.top, Spacing.xs)
            }

            // Feature list
            FocusCard {
                CommitmentFeatureList(mode: selectedMode)
            }
            .padding(.horizontal, Spacing.md)

            Spacer()

            // Continue button
            PrimaryButton(title: "Continue", action: onContinue)
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.lg)
        }
    }
}

#Preview {
    CommitmentLevelView(
        selectedMode: .constant(.standard),
        onContinue: {},
        onBack: {}
    )
}
