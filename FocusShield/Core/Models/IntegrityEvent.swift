import Foundation

// MARK: - Integrity Event Type

enum IntegrityEventType: String, Codable, CaseIterable {
    case limitExceeded = "limit_exceeded"
    case graceUsed = "grace_used"
    case extensionRequested = "extension_requested"
    case extensionApproved = "extension_approved"
    case extensionDenied = "extension_denied"
    case emergencyAccess = "emergency_access"
    case accountabilityDisabled = "accountability_disabled"
    case partnerRemoved = "partner_removed"
    case permissionsRevoked = "permissions_revoked"
    case limitsEdited = "limits_edited"
    case doneChosen = "done_chosen"

    var icon: String {
        switch self {
        case .limitExceeded: return "exclamationmark.triangle.fill"
        case .graceUsed: return "wind"
        case .extensionRequested: return "bubble.left.fill"
        case .extensionApproved: return "checkmark.bubble.fill"
        case .extensionDenied: return "xmark.bubble.fill"
        case .emergencyAccess: return "exclamationmark.shield.fill"
        case .accountabilityDisabled: return "shield.slash.fill"
        case .partnerRemoved: return "person.fill.xmark"
        case .permissionsRevoked: return "lock.slash.fill"
        case .limitsEdited: return "pencil"
        case .doneChosen: return "checkmark.circle.fill"
        }
    }

    var severity: EventSeverity {
        switch self {
        case .accountabilityDisabled, .partnerRemoved, .permissionsRevoked:
            return .critical
        case .limitExceeded, .emergencyAccess:
            return .high
        case .graceUsed, .extensionRequested, .limitsEdited:
            return .medium
        case .doneChosen, .extensionApproved, .extensionDenied:
            return .low
        }
    }

    var shouldNotifyPartner: Bool {
        switch self {
        case .limitExceeded, .emergencyAccess, .accountabilityDisabled,
             .partnerRemoved, .permissionsRevoked:
            return true
        case .graceUsed, .extensionRequested, .limitsEdited,
             .doneChosen, .extensionApproved, .extensionDenied:
            return false  // Or based on partner preferences
        }
    }

    var notificationMessage: String {
        switch self {
        case .limitExceeded:
            return "Daily limit exceeded"
        case .graceUsed:
            return "Grace period used"
        case .extensionRequested:
            return "Extension requested"
        case .extensionApproved:
            return "Extension approved"
        case .extensionDenied:
            return "Extension denied"
        case .emergencyAccess:
            return "Emergency access used"
        case .accountabilityDisabled:
            return "Accountability was disabled"
        case .partnerRemoved:
            return "You were removed as accountability partner"
        case .permissionsRevoked:
            return "App permissions were revoked"
        case .limitsEdited:
            return "Limits were edited"
        case .doneChosen:
            return "Chose to stop using app"
        }
    }
}

// MARK: - Event Severity

enum EventSeverity: Int, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    case critical = 3

    static func < (lhs: EventSeverity, rhs: EventSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var color: String {
        switch self {
        case .low: return "success"
        case .medium: return "neutral"
        case .high: return "warning"
        case .critical: return "danger"
        }
    }
}

// MARK: - Integrity Event

struct IntegrityEvent: Codable, Identifiable {
    let id: UUID
    let type: IntegrityEventType
    let timestamp: Date
    var appName: String?           // Only if user opted to share
    var additionalContext: String?
    var wasNotified: Bool = false
    var limitId: UUID?             // Reference to the limit that triggered this

    init(
        id: UUID = UUID(),
        type: IntegrityEventType,
        timestamp: Date = Date(),
        appName: String? = nil,
        additionalContext: String? = nil,
        wasNotified: Bool = false,
        limitId: UUID? = nil
    ) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.appName = appName
        self.additionalContext = additionalContext
        self.wasNotified = wasNotified
        self.limitId = limitId
    }

    var displayMessage: String {
        var message = type.notificationMessage
        if let appName = appName {
            message += " (\(appName))"
        }
        return message
    }
}
