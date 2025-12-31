import SwiftUI

struct BudgetSummaryView: View {
    let limits: [AppLimit]

    var body: some View {
        FocusCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Today's Budgets")
                    .font(.headlineMedium)

                if limits.isEmpty {
                    EmptyBudgetView()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.lg) {
                            ForEach(limits) { limit in
                                BudgetRing(
                                    progress: limit.progress,
                                    appName: limit.displayName,
                                    usedMinutes: limit.usedMinutesToday,
                                    totalMinutes: limit.effectiveDailyLimit
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Empty Budget View

struct EmptyBudgetView: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "clock.badge.plus")
                .font(.system(size: 32))
                .foregroundColor(.neutral.opacity(0.5))

            Text("No limits set yet")
                .font(.bodyMedium)
                .foregroundColor(.neutral)

            Text("Add your first limit to start tracking")
                .font(.labelSmall)
                .foregroundColor(.neutral.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        BudgetSummaryView(limits: AppLimit.sampleLimits)

        BudgetSummaryView(limits: [])
    }
    .padding()
    .background(Color.backgroundStart)
}
