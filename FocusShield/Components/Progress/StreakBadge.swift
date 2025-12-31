import SwiftUI

// MARK: - Streak Badge

struct StreakBadge: View {
    let days: Int
    var longestStreak: Int? = nil  // Optional: if provided, enables record detection
    var size: StreakBadgeSize = .medium

    private var status: StreakStatus {
        // Use longest streak if provided, otherwise use a simple threshold-based approach
        let longest = longestStreak ?? max(days, 7)  // Default: treat 7+ as potentially strong
        return StreakStatus(currentStreak: days, longestStreak: longest)
    }

    private var badgeColor: Color {
        switch status {
        case .none: return .neutral
        case .building: return .warning
        case .strong: return .focusPrimary
        case .record: return .success
        }
    }

    private var accessibilityLabel: String {
        if days == 0 {
            return "No current streak"
        } else if days == 1 {
            return "1 day streak"
        } else {
            return "\(days) day streak"
        }
    }

    var body: some View {
        HStack(spacing: size.spacing) {
            Image(systemName: days > 0 ? "flame.fill" : "flame")
                .font(.system(size: size.iconSize))
                .foregroundColor(badgeColor)

            Text("\(days)")
                .font(size.font)
                .fontWeight(.semibold)
                .foregroundColor(badgeColor)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(badgeColor.opacity(0.1))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Streak Badge Size

enum StreakBadgeSize {
    case small
    case medium
    case large

    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 24
        }
    }

    var font: Font {
        switch self {
        case .small: return .labelSmall
        case .medium: return .labelLarge
        case .large: return .headlineMedium
        }
    }

    var spacing: CGFloat {
        switch self {
        case .small: return 2
        case .medium: return 4
        case .large: return 6
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 6
        case .large: return 10
        }
    }
}

// MARK: - Large Streak Display

struct LargeStreakDisplay: View {
    let currentStreak: Int
    let longestStreak: Int

    private var status: StreakStatus {
        StreakStatus(currentStreak: currentStreak, longestStreak: longestStreak)
    }

    private var accessibilityLabel: String {
        var label = currentStreak == 1 ? "1 day streak" : "\(currentStreak) day streak"
        if longestStreak > currentStreak {
            label += ". Longest streak is \(longestStreak) days"
        } else if currentStreak > 0 && currentStreak >= longestStreak {
            label += ". This is your longest streak"
        }
        return label
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Flame icon
            Image(systemName: status.icon)
                .font(.system(size: 48))
                .foregroundColor(streakColor)
                .accessibilityHidden(true)

            // Current streak
            Text("\(currentStreak)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(currentStreak == 1 ? "day" : "days")
                .font(.headlineMedium)
                .foregroundColor(.neutral)

            // Status message
            Text(status.message)
                .font(.bodyMedium)
                .foregroundColor(.neutral)
                .multilineTextAlignment(.center)

            // Longest streak
            if longestStreak > currentStreak {
                HStack(spacing: Spacing.xs) {
                    Text("Longest:")
                        .foregroundColor(.neutral)
                    Text("\(longestStreak) days")
                        .fontWeight(.medium)
                }
                .font(.labelMedium)
            }
        }
        .padding(Spacing.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var streakColor: Color {
        switch status {
        case .none: return .neutral
        case .building: return .warning
        case .strong: return .focusPrimary
        case .record: return .success
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        HStack(spacing: Spacing.md) {
            StreakBadge(days: 0, size: .small)
            StreakBadge(days: 3, size: .medium)
            StreakBadge(days: 14, size: .large)
        }

        LargeStreakDisplay(currentStreak: 7, longestStreak: 14)
    }
    .padding()
    .background(Color.backgroundStart)
}
