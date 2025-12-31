import Foundation

// MARK: - Commitment Mode

enum CommitmentMode: String, CaseIterable, Codable, Identifiable {
    case gentle = "Gentle"
    case standard = "Standard"
    case locked = "Locked"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .gentle:
            return "Pause prompts and budgets. Easy to edit anytime."
        case .standard:
            return "App shields with 24-hour cooldown on edits."
        case .locked:
            return "Contact must approve extensions and edits."
        }
    }

    var iconName: String {
        switch self {
        case .gentle: return "leaf.fill"
        case .standard: return "shield.fill"
        case .locked: return "lock.fill"
        }
    }

    var editCooldownHours: Int? {
        switch self {
        case .gentle: return nil
        case .standard: return 24
        case .locked: return nil  // Requires contact approval
        }
    }

    var requiresContactApproval: Bool {
        self == .locked
    }

    var shieldsEnabled: Bool {
        self != .gentle
    }

    var featureList: [String] {
        switch self {
        case .gentle:
            return [
                "Soft reminders when limits approached",
                "Easy to adjust limits anytime",
                "No blocking, just awareness"
            ]
        case .standard:
            return [
                "Apps blocked when limit reached",
                "24-hour cooldown before editing limits",
                "Accountability partner notified of overages"
            ]
        case .locked:
            return [
                "Apps blocked when limit reached",
                "Partner approval needed for changes",
                "Maximum accountability protection"
            ]
        }
    }
}
