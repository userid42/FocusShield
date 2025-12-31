import Foundation

// MARK: - Shield Option

enum ShieldOption: String, CaseIterable, Identifiable {
    case done = "I'm Done"
    case grace = "2-min Grace"
    case request = "Request 10 min"
    case emergency = "Emergency Access"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .done: return "Return home"
        case .grace: return "10s pause first"
        case .request: return "Asks your partner"
        case .emergency: return "Notifies partner"
        }
    }

    var iconName: String {
        switch self {
        case .done: return "checkmark.circle.fill"
        case .grace: return "wind"
        case .request: return "bubble.left.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        }
    }

    var requiresAccountability: Bool {
        self == .request || self == .emergency
    }

    var color: ShieldOptionColor {
        switch self {
        case .done: return .primary
        case .grace: return .secondary
        case .request: return .secondary
        case .emergency: return .danger
        }
    }

    var analyticsName: String {
        switch self {
        case .done: return "done_chosen"
        case .grace: return "grace_used"
        case .request: return "extension_requested"
        case .emergency: return "emergency_access"
        }
    }
}

// MARK: - Shield Option Color

enum ShieldOptionColor {
    case primary
    case secondary
    case danger

    var backgroundColor: String {
        switch self {
        case .primary: return "focusPrimary"
        case .secondary: return "cardBackground"
        case .danger: return "danger"
        }
    }

    var foregroundColor: String {
        switch self {
        case .primary: return "white"
        case .secondary: return "primary"
        case .danger: return "white"
        }
    }
}
