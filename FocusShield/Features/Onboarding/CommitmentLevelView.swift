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
                    .accessibilityAddTraits(.isHeader)

                Text("You can change this anytime")
                    .font(.bodyMedium)
                    .foregroundColor(.neutral)
            }

            // Mode options
            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(CommitmentMode.allCases) { mode in
                        SelectableOptionCard(
                            option: mode,
                            isSelected: selectedMode == mode,
                            onTap: {
                                withAnimation(.focusSpring) {
                                    selectedMode = mode
                                }
                            },
                            showRecommendedBadge: mode == .standard
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
            }

            // Feature list
            FocusCard {
                CommitmentFeatureList(mode: selectedMode)
            }
            .padding(.horizontal, Spacing.md)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Features for \(selectedMode.rawValue) mode")

            Spacer()

            // Continue button
            PrimaryButton(
                title: "Continue",
                action: onContinue,
                accessibilityHint: "Continue with \(selectedMode.rawValue) commitment level"
            )
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
