import Foundation
import Combine

// MARK: - Accountability Service

@MainActor
class AccountabilityService: ObservableObject {
    static let shared = AccountabilityService()

    @Published var partner: AccountabilityPartner?
    @Published var pendingRequests: [ExtensionRequest] = []
    @Published var isNotifying: Bool = false

    private let persistence = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()

    // Rate limiting
    private var lastNotificationTime: Date?
    private let minimumNotificationInterval: TimeInterval = 300 // 5 minutes

    private init() {
        loadPartner()
    }

    // MARK: - Partner Management

    func loadPartner() {
        partner = persistence.partner
    }

    func setPartner(_ partner: AccountabilityPartner) {
        self.partner = partner
        persistence.savePartner(partner)
    }

    func removePartner() {
        // This will log the integrity event
        persistence.removePartner()
        partner = nil
    }

    func updatePartnerStatus(_ status: PartnerStatus) {
        guard var currentPartner = partner else { return }
        currentPartner.status = status
        if status == .active {
            currentPartner.acceptedAt = Date()
        }
        setPartner(currentPartner)
    }

    // MARK: - Notifications

    func notifyPartner(event: IntegrityEvent) async {
        guard let partner = partner,
              partner.status == .active else { return }

        // Check quiet hours
        if let quietHours = partner.quietHours,
           quietHours.isCurrentlyQuiet() {
            return
        }

        // Rate limiting
        if let lastTime = lastNotificationTime,
           Date().timeIntervalSince(lastTime) < minimumNotificationInterval {
            return
        }

        // Check if event type should notify based on preferences
        guard shouldNotify(event: event, preferences: partner.sharingPreferences) else { return }

        isNotifying = true
        lastNotificationTime = Date()

        let message = buildMessage(for: event, partner: partner)

        do {
            switch partner.contactMethod {
            case .email(let address):
                try await sendEmail(to: address, message: message)
            case .sms(let phone):
                try await sendSMS(to: phone, message: message)
            case .pushNotification(let token):
                try await sendPushNotification(to: token, message: message)
            }

            // Mark event as notified
            markEventNotified(event)
        } catch {
            print("Failed to notify partner: \(error)")
        }

        isNotifying = false
    }

    private func shouldNotify(event: IntegrityEvent, preferences: SharingPreferences) -> Bool {
        switch event.type {
        case .limitExceeded:
            return preferences.notifyOnLimitExceeded
        case .accountabilityDisabled, .partnerRemoved, .permissionsRevoked:
            return preferences.notifyOnIntegrityEvents
        case .emergencyAccess:
            return preferences.notifyOnLimitExceeded
        default:
            return false
        }
    }

    private func buildMessage(for event: IntegrityEvent, partner: AccountabilityPartner) -> String {
        var message = "FocusShield: \(event.type.notificationMessage)"

        if partner.sharingPreferences.includeAppNames, let appName = event.appName {
            message += " (\(appName))"
        }

        return message
    }

    // MARK: - Send Methods (Stubs - would integrate with backend)

    private func sendEmail(to address: String, message: String) async throws {
        // Integration with SendGrid/Mailgun or backend API
        // For now, this is a stub
        print("Would send email to \(address): \(message)")
    }

    private func sendSMS(to phone: String, message: String) async throws {
        // Integration with Twilio or backend API
        // For now, this is a stub
        print("Would send SMS to \(phone): \(message)")
    }

    private func sendPushNotification(to token: String, message: String) async throws {
        // Integration with APNs or Firebase
        // For now, this is a stub
        print("Would send push to \(token): \(message)")
    }

    private func markEventNotified(_ event: IntegrityEvent) {
        var events = persistence.integrityEvents
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].wasNotified = true
            persistence.saveIntegrityEvents(events)
        }
    }

    // MARK: - Extension Requests

    func requestExtension(minutes: Int, for limitId: UUID, reason: String?) async -> Bool {
        guard let partner = partner,
              partner.status == .active else { return false }

        let request = ExtensionRequest(
            limitId: limitId,
            requestedMinutes: minutes,
            reason: reason
        )

        pendingRequests.append(request)

        // Notify partner about the request
        let event = IntegrityEvent(
            type: .extensionRequested,
            additionalContext: "Requested \(minutes) minutes"
        )

        await notifyPartner(event: event)

        // For now, auto-approve after a delay (in real app, would wait for partner response)
        // In production, this would be handled by a backend
        return true
    }

    func approveRequest(_ request: ExtensionRequest) {
        guard let index = pendingRequests.firstIndex(where: { $0.id == request.id }) else { return }
        pendingRequests[index].status = .approved
        pendingRequests[index].respondedAt = Date()

        persistence.logIntegrityEvent(.extensionApproved, context: "\(request.requestedMinutes) minutes")
    }

    func denyRequest(_ request: ExtensionRequest) {
        guard let index = pendingRequests.firstIndex(where: { $0.id == request.id }) else { return }
        pendingRequests[index].status = .denied
        pendingRequests[index].respondedAt = Date()

        persistence.logIntegrityEvent(.extensionDenied)
    }

    // MARK: - Invite

    func generateInviteMessage() -> String {
        """
        I'm using FocusShield to build better phone habits, and I'd like you to be my accountability partner.

        When I exceed my limits or disable protection, you'll receive a brief notification - no surveillance, just awareness.

        Download FocusShield to accept: [App Store Link]

        Or simply reply to confirm you're willing to be notified.
        """
    }
}

// MARK: - Extension Request

struct ExtensionRequest: Identifiable, Codable {
    let id: UUID
    let limitId: UUID
    let requestedMinutes: Int
    let reason: String?
    let requestedAt: Date
    var status: ExtensionRequestStatus
    var respondedAt: Date?

    init(
        id: UUID = UUID(),
        limitId: UUID,
        requestedMinutes: Int,
        reason: String? = nil,
        requestedAt: Date = Date(),
        status: ExtensionRequestStatus = .pending
    ) {
        self.id = id
        self.limitId = limitId
        self.requestedMinutes = requestedMinutes
        self.reason = reason
        self.requestedAt = requestedAt
        self.status = status
    }
}

enum ExtensionRequestStatus: String, Codable {
    case pending
    case approved
    case denied
    case expired
}
