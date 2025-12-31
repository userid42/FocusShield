import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var activeLimits: [AppLimit] = []
    @Published var partner: AccountabilityPartner?
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var daysWithinLimitsThisWeek: Int = 0
    @Published var currentInsight: Insight?
    @Published var isLoading: Bool = false

    private let persistence = PersistenceService.shared
    private let analytics = AnalyticsService.shared
    private var cancellables = Set<AnyCancellable>()

    var greeting: String {
        Date().greeting
    }

    var dateString: String {
        Date().displayString
    }

    var isAccountabilityActive: Bool {
        partner?.status == .active
    }

    var showWeeklySummary: Bool {
        daysWithinLimitsThisWeek > 0
    }

    init() {
        setupBindings()
    }

    private func setupBindings() {
        persistence.$limits
            .receive(on: DispatchQueue.main)
            .assign(to: &$activeLimits)

        persistence.$partner
            .receive(on: DispatchQueue.main)
            .assign(to: &$partner)

        persistence.$userProgress
            .receive(on: DispatchQueue.main)
            .map { $0.currentStreak }
            .assign(to: &$currentStreak)

        persistence.$userProgress
            .receive(on: DispatchQueue.main)
            .map { $0.longestStreak }
            .assign(to: &$longestStreak)

        persistence.$userProgress
            .receive(on: DispatchQueue.main)
            .map { progress in
                progress.weeklyHistory.filter { $0.withinAllLimits }.count
            }
            .assign(to: &$daysWithinLimitsThisWeek)
    }

    func loadData() {
        isLoading = true
        persistence.loadAll()

        // Generate insight
        let insights = analytics.generateWeeklyInsights()
        currentInsight = insights.first

        isLoading = false
    }

    func refresh() async {
        loadData()
    }

    func startFocusBlock() {
        HapticPattern.impact()
        // Start a 1-hour focus block
        ScreenTimeService.shared.applyShields()
    }
}
