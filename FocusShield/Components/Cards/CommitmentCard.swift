import SwiftUI

// MARK: - Commitment Card

struct CommitmentCard: View {
    let mode: CommitmentMode
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

                    Image(systemName: mode.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .focusPrimary : .neutral)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.headlineMedium)
                        .foregroundColor(.primary)

                    Text(mode.description)
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

// MARK: - Commitment Feature List

struct CommitmentFeatureList: View {
    let mode: CommitmentMode

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ForEach(mode.featureList, id: \.self) { feature in
                HStack(alignment: .top, spacing: Spacing.sm) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.success)

                    Text(feature)
                        .font(.bodySmall)
                        .foregroundColor(.neutral)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        CommitmentCard(
            mode: .gentle,
            isSelected: false
        ) {}

        CommitmentCard(
            mode: .standard,
            isSelected: true
        ) {}

        CommitmentCard(
            mode: .locked,
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color.backgroundStart)
}
