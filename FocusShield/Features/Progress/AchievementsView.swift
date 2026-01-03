import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var persistence: PersistenceService

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Summary
                AchievementSummaryCard(
                    unlocked: persistence.achievements.unlockedCount,
                    total: persistence.achievements.totalCount
                )
                .padding(.horizontal, Spacing.md)

                // Categories
                ForEach(AchievementCategory.allCases, id: \.rawValue) { category in
                    AchievementCategorySection(
                        category: category,
                        achievements: achievementsForCategory(category)
                    )
                }
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.backgroundStart.ignoresSafeArea())
        .navigationTitle("Achievements")
    }

    private func achievementsForCategory(_ category: AchievementCategory) -> [Achievement] {
        persistence.achievements.achievements.filter { achievement in
            achievement.definition?.category == category
        }
    }
}

// MARK: - Achievement Summary Card

struct AchievementSummaryCard: View {
    let unlocked: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(unlocked) / Double(total)
    }

    private var accessibilityLabel: String {
        let percent = Int(progress * 100)
        return "\(unlocked) of \(total) achievements unlocked, \(percent) percent complete"
    }

    var body: some View {
        FocusCard {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("\(unlocked) of \(total)")
                        .font(.displayMedium)

                    Text("achievements unlocked")
                        .font(.labelMedium)
                        .foregroundColor(.neutral)
                }

                Spacer()

                CircularProgressView(
                    progress: progress,
                    color: .warning,
                    lineWidth: 8
                )
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.warning)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Achievement Category Section

struct AchievementCategorySection: View {
    let category: AchievementCategory
    let achievements: [Achievement]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: category.icon)
                    .foregroundColor(.focusPrimary)
                Text(category.rawValue)
                    .font(.headlineMedium)
            }
            .padding(.horizontal, Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement

    private var definition: AchievementDefinition? {
        achievement.definition
    }

    private var accessibilityLabel: String {
        let title = definition?.title ?? "Achievement"
        let description = definition?.description ?? ""
        if achievement.isUnlocked {
            return "\(title), \(description), unlocked"
        } else {
            return "\(title), \(description), \(achievement.displayProgress)"
        }
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.warning.opacity(0.2) : Color.neutral.opacity(0.1))
                    .frame(width: 64, height: 64)

                Image(systemName: definition?.iconName ?? "star.fill")
                    .font(.system(size: 28))
                    .foregroundColor(achievement.isUnlocked ? .warning : .neutral.opacity(0.5))
            }
            .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(definition?.title ?? "")
                    .font(.labelMedium)
                    .foregroundColor(achievement.isUnlocked ? .primary : .neutral)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if achievement.isUnlocked {
                    Text("Unlocked")
                        .font(.labelSmall)
                        .foregroundColor(.success)
                } else {
                    Text(achievement.displayProgress)
                        .font(.labelSmall)
                        .foregroundColor(.neutral)
                }
            }
        }
        .frame(width: 100)
        .padding(Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .opacity(achievement.isUnlocked ? 1 : 0.7)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
            .environmentObject(PersistenceService.shared)
    }
}
