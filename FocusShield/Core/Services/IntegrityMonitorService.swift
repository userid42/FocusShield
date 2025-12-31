import Foundation
import FamilyControls
import Combine

// MARK: - Integrity Monitor Service

@MainActor
class IntegrityMonitorService: ObservableObject {
    static let shared = IntegrityMonitorService()

    @Published var lastKnownAuthStatus: AuthorizationStatus = .notDetermined
    @Published var isMonitoring: Bool = false

    private var checkTimer: Timer?
    private let persistence = PersistenceService.shared
    private let accountabilityService = AccountabilityService.shared

    private init() {
        startMonitoring()
    }

    // MARK: - Monitoring

    func startMonitoring() {
        guard !isMonitoring else { return }

        lastKnownAuthStatus = AuthorizationCenter.shared.authorizationStatus

        // Check every 60 seconds
        checkTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkIntegrity()
            }
        }

        isMonitoring = true
    }

    func stopMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
        isMonitoring = false
    }

    func checkIntegrity() {
        checkPermissions()
        checkAccountabilityStatus()
    }

    // MARK: - Permission Checks

    private func checkPermissions() {
        let currentStatus = AuthorizationCenter.shared.authorizationStatus

        // Check if permissions were revoked
        if lastKnownAuthStatus == .approved && currentStatus != .approved {
            logAndNotify(.permissionsRevoked)
        }

        lastKnownAuthStatus = currentStatus
    }

    // MARK: - Accountability Checks

    private func checkAccountabilityStatus() {
        let wasEnabled = UserDefaults.appGroup.bool(forKey: "accountabilityWasEnabled")
        let isEnabled = persistence.isAccountabilityEnabled

        if wasEnabled && !isEnabled {
            // Already logged by PersistenceService, just notify
            Task {
                let event = IntegrityEvent(type: .accountabilityDisabled)
                await accountabilityService.notifyPartner(event: event)
            }
        }

        UserDefaults.appGroup.set(isEnabled, forKey: "accountabilityWasEnabled")
    }

    // MARK: - Logging & Notification

    private func logAndNotify(_ eventType: IntegrityEventType, appName: String? = nil, context: String? = nil) {
        // Log the event
        persistence.logIntegrityEvent(eventType, appName: appName, context: context)

        // Notify partner
        let event = IntegrityEvent(
            type: eventType,
            appName: appName,
            additionalContext: context
        )

        Task {
            await accountabilityService.notifyPartner(event: event)
        }
    }

    // MARK: - Manual Logging

    func logLimitExceeded(limitName: String?, appName: String?) {
        logAndNotify(.limitExceeded, appName: appName, context: limitName)
    }

    func logGraceUsed(appName: String?) {
        persistence.logIntegrityEvent(.graceUsed, appName: appName)
    }

    func logDoneChosen(appName: String?) {
        persistence.logIntegrityEvent(.doneChosen, appName: appName)
    }

    func logEmergencyAccess(appName: String?, reason: String?) {
        logAndNotify(.emergencyAccess, appName: appName, context: reason)
    }

    func logLimitsEdited() {
        persistence.logIntegrityEvent(.limitsEdited)
    }
}
