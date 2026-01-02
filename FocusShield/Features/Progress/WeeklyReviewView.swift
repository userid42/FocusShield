import SwiftUI

struct WeeklyReviewView: View {
    @EnvironmentObject var persistence: PersistenceService
    @StateObject private var viewModel = WeeklyReviewViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Week summary card
                    WeekSummaryCard(summary: viewModel.summary)
                        .padding(.horizontal, Spacing.md)

                    // Week calendar
                    WeekCalendarView(records: viewModel.records)
                        .padding(.horizontal, Spacing.md)

                    // Insights
                    if !viewModel.insights.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Insights")
                                .font(.headlineMedium)
                                .padding(.horizontal, Spacing.md)

                            ForEach(viewModel.insights) { insight in
                                InsightCard(insight: insight)
                                    .padding(.horizontal, Spacing.md)
                            }
                        }
                    }

                    // Streak section
                    NavigationLink {
                        StreakView()
                    } label: {
                        StreakCard(streak: viewModel.currentStreak, longest: viewModel.longestStreak)
                            .padding(.horizontal, Spacing.md)
                    }
                    .buttonStyle(.plain)

                    // Achievements teaser
                    NavigationLink {
                        AchievementsView()
                    } label: {
                        AchievementsTeaserCard(
                            unlockedCount: viewModel.unlockedAchievements,
                            totalCount: viewModel.totalAchievements
                        )
                        .padding(.horizontal, Spacing.md)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, Spacing.md)
            }
            .background(
                LinearGradient.backgroundGradient
                    .ignoresSafeArea()
            )
            .navigationTitle("Progress")
            .task {
                viewModel.loadData()
            }
        }
    }
}

// MARK: - View Model

@MainActor
class WeeklyReviewViewModel: ObservableObject {
    @Published var records: [DailyRecord] = []
    @Published var insights: [Insight] = []
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var unlockedAchievements: Int = 0
    @Published var totalAchievements: Int = 0

    private let persistence = PersistenceService.shared
    private let analytics = AnalyticsService.shared

    var summary: WeeklySummary {
        analytics.generateWeeklySummary()
    }

    func loadData() {
        records = persistence.userProgress.weeklyHistory
        insights = analytics.generateWeeklyInsights()
        currentStreak = persistence.userProgress.currentStreak
        longestStreak = persistence.userProgress.longestStreak
        unlockedAchievements = persistence.achievements.unlockedCount
        totalAchievements = persistence.achievements.totalCount
    }
}

// MARK: - Week Summary Card

struct WeekSummaryCard: View {
    let summary: WeeklySummary

    var body: some View {
        FocusCard {
            VStack(spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(summary.daysWithinLimits)/7")
                            .font(.displayMedium)
                            .foregroundColor(.focusPrimary)

                        Text("days within limits")
                            .font(.labelMedium)
                            .foregroundColor(.neutral)
                    }

                    Spacer()

                    CircularProgressView(
                        progress: summary.successRate,
                        color: summary.successRate >= 0.7 ? .success : .focusPrimary,
                        lineWidth: 8
                    )
                    .frame(width: 60, height: 60)
                }

                Divider()

                HStack {
                    StatItem(label: "Avg Screen Time", value: summary.displayAverageScreenTime)
                    Spacer()
                    StatItem(label: "Done Chosen", value: "\(summary.totalDoneChosen)x")
                    Spacer()
                    StatItem(label: "Emergency", value: "\(summary.totalEmergencyAccess)x")
                }
            }
        }
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headlineMedium)

            Text(label)
                .font(.labelSmall)
                .foregroundColor(.neutral)
        }
    }
}

// MARK: - Week Calendar View

struct WeekCalendarView: View {
    let records: [DailyRecord]

    var body: some View {
        FocusCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("This Week")
                    .font(.headlineMedium)

                WeekProgressView(records: records)
            }
        }
    }
}

// MARK: - Streak Card

struct StreakCard: View {
    let streak: Int
    let longest: Int

    var body: some View {
        FocusCard {
            HStack {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: streak > 0 ? "flame.fill" : "flame")
                        .font(.system(size: 24))
                        .foregroundColor(streak > 0 ? .warning : .neutral)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(streak) day streak")
                            .font(.headlineMedium)

                        Text("Longest: \(longest) days")
                            .font(.labelSmall)
                            .foregroundColor(.neutral)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.neutral)
            }
        }
    }
}

// MARK: - Achievements Teaser Card

struct AchievementsTeaserCard: View {
    let unlockedCount: Int
    let totalCount: Int

    var body: some View {
        FocusCard {
            HStack {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.warning)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Achievements")
                            .font(.headlineMedium)

                        Text("\(unlockedCount)/\(totalCount) unlocked")
                            .font(.labelSmall)
                            .foregroundColor(.neutral)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.neutral)
            }
        }
    }
}

#Preview {
    WeeklyReviewView()
        .environmentObject(PersistenceService.shared)
}
