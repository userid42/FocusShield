import Foundation
import Combine

// MARK: - App Configuration Constants

enum AppConstants {
    /// App Group identifier for sharing data with extensions
    /// This is used by the main app and all extensions to share data via UserDefaults
    static let appGroupId = "group.com.focusshield.shared"

    /// Maximum number of integrity events to keep
    static let maxIntegrityEvents = 100

    /// Maximum number of daily records to keep
    static let maxDailyRecords = 90
}

// MARK: - Persistence Service

@MainActor
class PersistenceService: ObservableObject {
    static let shared = PersistenceService()

    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: AppConstants.appGroupId) ?? .standard
    }

    // MARK: - Published Properties

    @Published var user: User?
    @Published var limits: [AppLimit] = []
    @Published var partner: AccountabilityPartner?
    @Published var gracePool: GracePool = GracePool()
    @Published var userProgress: UserProgress = UserProgress()
    @Published var achievements: AchievementsManager = AchievementsManager()
    @Published var integrityEvents: [IntegrityEvent] = []
    @Published var timeWindows: [TimeWindow] = []
    @Published var intentions: [ImplementationIntention] = []
    @Published var appSettings: AppSettings = AppSettings()

    // MARK: - Keys

    private enum Keys {
        static let user = "user"
        static let limits = "limits"
        static let partner = "partner"
        static let gracePool = "gracePool"
        static let userProgress = "userProgress"
        static let achievements = "achievements"
        static let integrityEvents = "integrityEvents"
        static let timeWindows = "timeWindows"
        static let intentions = "intentions"
        static let dailyRecords = "dailyRecords"
        static let onboardingCompleted = "onboardingCompleted"
        static let accountabilityEnabled = "accountabilityEnabled"
        static let accountabilityWasEnabled = "accountabilityWasEnabled"
        static let showAppNameOnShield = "showAppNameOnShield"
        static let selectedAppsData = "selectedAppsData"
        static let appSettings = "appSettings"
    }

    // MARK: - Initialization

    private init() {
        loadAll()
    }

    // MARK: - Load All Data

    func loadAll() {
        user = load(User.self, forKey: Keys.user)
        limits = load([AppLimit].self, forKey: Keys.limits) ?? []
        partner = load(AccountabilityPartner.self, forKey: Keys.partner)
        gracePool = load(GracePool.self, forKey: Keys.gracePool) ?? GracePool()
        userProgress = load(UserProgress.self, forKey: Keys.userProgress) ?? UserProgress()
        achievements = load(AchievementsManager.self, forKey: Keys.achievements) ?? AchievementsManager()
        integrityEvents = load([IntegrityEvent].self, forKey: Keys.integrityEvents) ?? []
        timeWindows = load([TimeWindow].self, forKey: Keys.timeWindows) ?? []
        intentions = load([ImplementationIntention].self, forKey: Keys.intentions) ?? []
        appSettings = load(AppSettings.self, forKey: Keys.appSettings) ?? AppSettings()

        // Reset grace pool if needed
        gracePool.resetIfNeeded()
    }

    // MARK: - User

    func saveUser(_ user: User) {
        self.user = user
        save(user, forKey: Keys.user)
    }

    func updateOnboardingCompleted(_ completed: Bool) {
        var updatedUser = user ?? User()
        updatedUser.onboardingCompleted = completed
        saveUser(updatedUser)
    }

    // MARK: - Limits

    func saveLimits(_ limits: [AppLimit]) {
        self.limits = limits
        save(limits, forKey: Keys.limits)
    }

    func addLimit(_ limit: AppLimit) {
        var updatedLimits = limits
        updatedLimits.append(limit)
        saveLimits(updatedLimits)
    }

    func updateLimit(_ limit: AppLimit) {
        if let index = limits.firstIndex(where: { $0.id == limit.id }) {
            var updatedLimits = limits
            updatedLimits[index] = limit
            saveLimits(updatedLimits)
        }
    }

    func removeLimit(id: UUID) {
        let updatedLimits = limits.filter { $0.id != id }
        saveLimits(updatedLimits)
    }

    // MARK: - Partner

    func savePartner(_ partner: AccountabilityPartner?) {
        self.partner = partner
        if let partner = partner {
            save(partner, forKey: Keys.partner)
            userDefaults.set(true, forKey: Keys.accountabilityEnabled)
        } else {
            userDefaults.removeObject(forKey: Keys.partner)
            userDefaults.set(false, forKey: Keys.accountabilityEnabled)
        }
    }

    func removePartner() {
        // Log integrity event before removing
        logIntegrityEvent(.partnerRemoved)
        savePartner(nil)
    }

    // MARK: - Grace Pool

    func saveGracePool(_ pool: GracePool) {
        self.gracePool = pool
        save(pool, forKey: Keys.gracePool)
    }

    func useGrace() -> Bool {
        var pool = gracePool
        let success = pool.useGrace()
        if success {
            saveGracePool(pool)
        }
        return success
    }

    // MARK: - Progress

    func saveUserProgress(_ progress: UserProgress) {
        self.userProgress = progress
        save(progress, forKey: Keys.userProgress)
    }

    func recordDailyRecord(_ record: DailyRecord) {
        var progress = userProgress
        progress.recordDay(record)
        saveUserProgress(progress)

        // Update achievements
        updateAchievementsFromProgress(progress, record: record)
    }

    // MARK: - Achievements

    func saveAchievements(_ manager: AchievementsManager) {
        self.achievements = manager
        save(manager, forKey: Keys.achievements)
    }

    func updateAchievement(_ id: String, progress: Int) {
        var manager = achievements
        manager.updateAchievement(id, progress: progress)
        saveAchievements(manager)
    }

    private func updateAchievementsFromProgress(_ progress: UserProgress, record: DailyRecord) {
        var manager = achievements

        // Update streak achievements
        manager.updateAchievement(AchievementDefinition.streak3.rawValue, progress: progress.currentStreak)
        manager.updateAchievement(AchievementDefinition.streak7.rawValue, progress: progress.currentStreak)
        manager.updateAchievement(AchievementDefinition.streak14.rawValue, progress: progress.currentStreak)
        manager.updateAchievement(AchievementDefinition.streak30.rawValue, progress: progress.currentStreak)

        // Update first day
        if progress.totalDaysWithinLimits >= 1 {
            manager.updateAchievement(AchievementDefinition.firstDay.rawValue, progress: 1)
        }

        saveAchievements(manager)
    }

    // MARK: - Integrity Events

    func saveIntegrityEvents(_ events: [IntegrityEvent]) {
        self.integrityEvents = events
        save(events, forKey: Keys.integrityEvents)
    }

    func logIntegrityEvent(_ type: IntegrityEventType, appName: String? = nil, context: String? = nil) {
        let event = IntegrityEvent(
            type: type,
            appName: appName,
            additionalContext: context
        )
        var events = integrityEvents
        events.append(event)

        // Keep only last N events to prevent unbounded growth
        if events.count > AppConstants.maxIntegrityEvents {
            events = Array(events.suffix(AppConstants.maxIntegrityEvents))
        }

        saveIntegrityEvents(events)
    }

    // MARK: - Time Windows

    func saveTimeWindows(_ windows: [TimeWindow]) {
        self.timeWindows = windows
        save(windows, forKey: Keys.timeWindows)
    }

    func addTimeWindow(_ window: TimeWindow) {
        var windows = timeWindows
        windows.append(window)
        saveTimeWindows(windows)
    }

    func updateTimeWindow(_ window: TimeWindow) {
        if let index = timeWindows.firstIndex(where: { $0.id == window.id }) {
            var windows = timeWindows
            windows[index] = window
            saveTimeWindows(windows)
        }
    }

    func removeTimeWindow(id: UUID) {
        let windows = timeWindows.filter { $0.id != id }
        saveTimeWindows(windows)
    }

    // MARK: - Intentions

    func saveIntentions(_ intentions: [ImplementationIntention]) {
        self.intentions = intentions
        save(intentions, forKey: Keys.intentions)
    }

    func addIntention(_ intention: ImplementationIntention) {
        var updatedIntentions = intentions
        updatedIntentions.append(intention)
        saveIntentions(updatedIntentions)
    }

    // MARK: - App Settings

    func saveAppSettings(_ settings: AppSettings) {
        self.appSettings = settings
        save(settings, forKey: Keys.appSettings)
    }

    func updateAppearanceMode(_ mode: AppearanceMode) {
        var settings = appSettings
        settings.appearanceMode = mode
        saveAppSettings(settings)
    }

    func updateProFeaturesEnabled(_ enabled: Bool) {
        var settings = appSettings
        settings.proFeaturesEnabled = enabled
        saveAppSettings(settings)
    }

    func updateHapticsEnabled(_ enabled: Bool) {
        var settings = appSettings
        settings.hapticsEnabled = enabled
        saveAppSettings(settings)
    }

    // MARK: - Pro Feature Checks

    /// Check if a specific Pro feature is available
    func isProFeatureAvailable(_ feature: ProFeature) -> Bool {
        appSettings.proFeaturesEnabled
    }

    /// Check if user can add more limits (respects free tier)
    var canAddMoreLimits: Bool {
        appSettings.proFeaturesEnabled || limits.count < FreeTierLimits.maxLimits
    }

    /// Check if user can add more time windows (respects free tier)
    var canAddMoreTimeWindows: Bool {
        appSettings.proFeaturesEnabled || timeWindows.count < FreeTierLimits.maxTimeWindows
    }

    /// Check if user can add more intentions (respects free tier)
    var canAddMoreIntentions: Bool {
        appSettings.proFeaturesEnabled || intentions.count < FreeTierLimits.maxIntentions
    }

    // MARK: - Helper Methods

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key)
            LoggingService.shared.persistence("Saved \(key)", operation: .save)
        } catch {
            LoggingService.shared.persistence("Failed to save \(key)", operation: .encode, error: error)
        }
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        do {
            let result = try JSONDecoder().decode(type, from: data)
            LoggingService.shared.persistence("Loaded \(key)", operation: .load)
            return result
        } catch {
            LoggingService.shared.persistence("Failed to load \(key)", operation: .decode, error: error)
            return nil
        }
    }

    // MARK: - Simple Values

    var isOnboardingCompleted: Bool {
        get { userDefaults.bool(forKey: Keys.onboardingCompleted) }
        set { userDefaults.set(newValue, forKey: Keys.onboardingCompleted) }
    }

    var isAccountabilityEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.accountabilityEnabled) }
        set {
            let wasEnabled = userDefaults.bool(forKey: Keys.accountabilityEnabled)
            userDefaults.set(newValue, forKey: Keys.accountabilityEnabled)

            // Log integrity event if disabling
            if wasEnabled && !newValue {
                logIntegrityEvent(.accountabilityDisabled)
            }

            userDefaults.set(wasEnabled, forKey: Keys.accountabilityWasEnabled)
        }
    }

    var showAppNameOnShield: Bool {
        get { userDefaults.bool(forKey: Keys.showAppNameOnShield) }
        set { userDefaults.set(newValue, forKey: Keys.showAppNameOnShield) }
    }

    // MARK: - Reset

    func resetAllData() {
        let keys = [
            Keys.user, Keys.limits, Keys.partner, Keys.gracePool,
            Keys.userProgress, Keys.achievements, Keys.integrityEvents,
            Keys.timeWindows, Keys.intentions, Keys.dailyRecords,
            Keys.onboardingCompleted, Keys.accountabilityEnabled,
            Keys.accountabilityWasEnabled, Keys.showAppNameOnShield,
            Keys.selectedAppsData, Keys.appSettings
        ]

        for key in keys {
            userDefaults.removeObject(forKey: key)
        }

        loadAll()
    }
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    /// Shared UserDefaults for the app group (main app + extensions)
    static var appGroup: UserDefaults {
        UserDefaults(suiteName: AppConstants.appGroupId) ?? .standard
    }
}
