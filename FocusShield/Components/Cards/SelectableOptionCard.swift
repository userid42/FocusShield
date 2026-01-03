import SwiftUI

// MARK: - Selectable Option Protocol

/// Protocol for types that can be displayed in a selectable option card
protocol SelectableOption {
    var displayTitle: String { get }
    var displayDescription: String { get }
    var displayIcon: String { get }
}

// MARK: - Selectable Option Card

/// Generic reusable card component for displaying selectable options
/// Replaces duplicate code in GoalOptionCard and CommitmentCard
struct SelectableOptionCard<T: SelectableOption>: View {
    let option: T
    let isSelected: Bool
    let onTap: () -> Void
    var showRecommendedBadge: Bool = false

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

                    Image(systemName: option.displayIcon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .focusPrimary : .neutral)
                }
                .accessibilityHidden(true)

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(option.displayTitle)
                            .font(.headlineMedium)
                            .foregroundColor(.primary)

                        if showRecommendedBadge {
                            Text("RECOMMENDED")
                                .font(.labelSmall)
                                .fontWeight(.semibold)
                                .foregroundColor(.focusPrimary)
                                .padding(.horizontal, Spacing.xs)
                                .padding(.vertical, 2)
                                .background(Color.focusPrimary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    Text(option.displayDescription)
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
                        .accessibilityHidden(true)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
    }

    private var accessibilityLabel: String {
        var label = "\(option.displayTitle), \(option.displayDescription)"
        if showRecommendedBadge {
            label += ", recommended"
        }
        return label
    }
}

// MARK: - Protocol Conformances

extension UserGoal: SelectableOption {
    var displayTitle: String { rawValue }
    var displayDescription: String { description }
    var displayIcon: String { icon }
}

extension CommitmentMode: SelectableOption {
    var displayTitle: String { rawValue }
    var displayDescription: String { description }
    var displayIcon: String { iconName }
}
