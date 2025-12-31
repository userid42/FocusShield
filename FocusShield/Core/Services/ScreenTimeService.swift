import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

// MARK: - Screen Time Service

@MainActor
class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()

    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @Published var isMonitoring: Bool = false

    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        checkAuthorizationStatus()
    }

    var isAuthorized: Bool {
        authorizationStatus == .approved
    }

    // MARK: - App Selection

    func saveSelection(_ selection: FamilyActivitySelection) {
        selectedApps = selection

        // Save to UserDefaults for extensions
        if let encoded = try? PropertyListEncoder().encode(selection) {
            UserDefaults.appGroup.set(encoded, forKey: "selectedApps")
        }
    }

    func loadSelection() {
        if let data = UserDefaults.appGroup.data(forKey: "selectedApps"),
           let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) {
            selectedApps = selection
        }
    }

    // MARK: - Apply Shields

    func applyShields() {
        guard isAuthorized else { return }

        store.shield.applications = selectedApps.applicationTokens
        store.shield.applicationCategories = .specific(selectedApps.categoryTokens)
        store.shield.webDomains = selectedApps.webDomainTokens
    }

    func applyShields(for selection: FamilyActivitySelection) {
        guard isAuthorized else { return }

        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
    }

    func removeAllShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    func temporarilyRemoveShield(for minutes: Int) {
        removeAllShields()

        // Re-apply after the grace period
        DispatchQueue.main.asyncAfter(deadline: .now() + .minutes(minutes)) { [weak self] in
            self?.applyShields()
        }
    }

    // MARK: - Scheduling

    func scheduleMonitoring(for limits: [AppLimit]) throws {
        guard isAuthorized else { return }

        // Stop existing monitoring
        stopAllMonitoring()

        for limit in limits where limit.isActive {
            let activityName = DeviceActivityName(rawValue: limit.id.uuidString)

            let schedule = DeviceActivitySchedule(
                intervalStart: DateComponents(hour: 0, minute: 0),
                intervalEnd: DateComponents(hour: 23, minute: 59),
                repeats: true
            )

            // Create event for when threshold is reached
            var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

            // Decode the app tokens
            if let appData = limit.appTokensData,
               let apps = try? PropertyListDecoder().decode(Set<ApplicationToken>.self, from: appData) {

                let event = DeviceActivityEvent(
                    applications: apps,
                    categories: Set(),
                    webDomains: Set(),
                    threshold: DateComponents(minute: limit.dailyMinutes)
                )

                events[DeviceActivityEvent.Name(rawValue: "threshold_\(limit.id.uuidString)")] = event
            }

            // Decode category tokens
            if let categoryData = limit.categoryTokensData,
               let categories = try? PropertyListDecoder().decode(Set<ActivityCategoryToken>.self, from: categoryData) {

                let event = DeviceActivityEvent(
                    applications: Set(),
                    categories: categories,
                    webDomains: Set(),
                    threshold: DateComponents(minute: limit.dailyMinutes)
                )

                events[DeviceActivityEvent.Name(rawValue: "category_threshold_\(limit.id.uuidString)")] = event
            }

            if !events.isEmpty {
                try center.startMonitoring(activityName, during: schedule, events: events)
            }
        }

        isMonitoring = true
    }

    func scheduleTimeWindow(_ window: TimeWindow) throws {
        guard isAuthorized, window.isEnabled else { return }

        let activityName = DeviceActivityName(rawValue: "window_\(window.id.uuidString)")

        let schedule = DeviceActivitySchedule(
            intervalStart: window.startTime,
            intervalEnd: window.endTime,
            repeats: true
        )

        try center.startMonitoring(activityName, during: schedule)
    }

    func stopMonitoring(for limitId: UUID) {
        let activityName = DeviceActivityName(rawValue: limitId.uuidString)
        center.stopMonitoring([activityName])
    }

    func stopAllMonitoring() {
        center.stopMonitoring()
        isMonitoring = false
    }

    // MARK: - Focus Blocks

    func startFocusBlock(duration: TimeInterval, apps: FamilyActivitySelection) {
        guard isAuthorized else { return }

        applyShields(for: apps)

        // Schedule removal after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.removeAllShields()
        }
    }
}

// MARK: - DispatchTimeInterval Extension

extension DispatchTimeInterval {
    static func minutes(_ minutes: Int) -> DispatchTimeInterval {
        .seconds(minutes * 60)
    }
}
