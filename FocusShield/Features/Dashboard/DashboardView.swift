import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var persistence: PersistenceService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.greeting)
                                .font(.headlineLarge)
                                .accessibilityAddTraits(.isHeader)
                            Text(viewModel.dateString)
                                .font(.bodySmall)
                                .foregroundColor(.neutral)
                        }
                        .accessibilityElement(children: .combine)

                        Spacer()

                        // Streak badge
                        if viewModel.currentStreak > 0 {
                            StreakBadge(
                                days: viewModel.currentStreak,
                                longestStreak: viewModel.longestStreak
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    // Budget summary
                    BudgetSummaryView(limits: viewModel.activeLimits)

                    // Insight card
                    if let insight = viewModel.currentInsight {
                        InsightCard(insight: insight) {
                            // Handle action
                        }
                        .padding(.horizontal, Spacing.md)
                    }

                    // Quick actions
                    QuickActionsView(
                        onStartFocusBlock: { viewModel.startFocusBlock() },
                        onEditLimits: { }
                    )

                    // Accountability status
                    if let partner = viewModel.partner {
                        AccountabilityStatusCard(
                            partner: partner,
                            isActive: viewModel.isAccountabilityActive
                        )
                        .padding(.horizontal, Spacing.md)
                    }

                    // Weekly summary teaser
                    WeeklySummaryTeaser(
                        daysWithinLimits: viewModel.daysWithinLimitsThisWeek,
                        totalDays: 7
                    )
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.vertical, Spacing.md)
            }
            .background(
                LinearGradient.backgroundGradient
                    .ignoresSafeArea()
            )
            .navigationTitle("")
            .hideNavigationBar()
            .refreshable {
                await viewModel.refresh()
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(PersistenceService.shared)
}
