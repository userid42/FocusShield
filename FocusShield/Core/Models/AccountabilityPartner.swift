import Foundation

// MARK: - Accountability Partner

struct AccountabilityPartner: Codable, Identifiable {
    let id: UUID
    var name: String
    var contactMethod: ContactMethod
    var status: PartnerStatus
    var sharingPreferences: SharingPreferences
    var quietHours: QuietHours?
    var invitedAt: Date
    var acceptedAt: Date?

    init(
        id: UUID = UUID(),
        name: String,
        contactMethod: ContactMethod,
        status: PartnerStatus = .pending,
        sharingPreferences: SharingPreferences = SharingPreferences(),
        quietHours: QuietHours? = QuietHours(),
        invitedAt: Date = Date(),
        acceptedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.contactMethod = contactMethod
        self.status = status
        self.sharingPreferences = sharingPreferences
        self.quietHours = quietHours
        self.invitedAt = invitedAt
        self.acceptedAt = acceptedAt
    }
}

// MARK: - Contact Method

enum ContactMethod: Codable, Equatable {
    case sms(phoneNumber: String)
    case email(address: String)
    case pushNotification(deviceToken: String)

    var displayValue: String {
        switch self {
        case .sms(let phone):
            return phone
        case .email(let address):
            return address
        case .pushNotification:
            return "Push Notification"
        }
    }

    /// Masked display value for privacy (e.g., "j***@example.com")
    var maskedDisplayValue: String {
        switch self {
        case .sms(let phone):
            return maskPhoneNumber(phone)
        case .email(let address):
            return maskEmail(address)
        case .pushNotification:
            return "Push Notification"
        }
    }

    var icon: String {
        switch self {
        case .sms:
            return "message.fill"
        case .email:
            return "envelope.fill"
        case .pushNotification:
            return "bell.fill"
        }
    }

    var contactType: String {
        switch self {
        case .sms: return "SMS"
        case .email: return "Email"
        case .pushNotification: return "Push"
        }
    }

    // MARK: - Private Helpers

    private func maskEmail(_ email: String) -> String {
        let parts = email.split(separator: "@")
        guard parts.count == 2 else { return "***@***" }

        let username = String(parts[0])
        let domain = String(parts[1])

        let maskedUsername: String
        if username.count <= 2 {
            maskedUsername = String(repeating: "*", count: username.count)
        } else {
            maskedUsername = String(username.prefix(1)) + String(repeating: "*", count: username.count - 2) + String(username.suffix(1))
        }

        return "\(maskedUsername)@\(domain)"
    }

    private func maskPhoneNumber(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }
        guard digits.count >= 4 else { return "****" }

        let lastFour = String(digits.suffix(4))
        return "***-***-\(lastFour)"
    }
}

// MARK: - Partner Status

enum PartnerStatus: String, Codable {
    case pending = "Pending"
    case active = "Active"
    case declined = "Declined"
    case removed = "Removed"

    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .active: return "checkmark.circle.fill"
        case .declined: return "xmark.circle.fill"
        case .removed: return "person.fill.xmark"
        }
    }

    var color: String {
        switch self {
        case .pending: return "warning"
        case .active: return "success"
        case .declined: return "danger"
        case .removed: return "neutral"
        }
    }
}

// MARK: - Sharing Preferences

struct SharingPreferences: Codable {
    var notifyOnLimitExceeded: Bool = true
    var notifyOnIntegrityEvents: Bool = true
    var includeAppNames: Bool = false         // Privacy: off by default
    var includeTimeSpent: Bool = false
    var notifyOnDailySuccess: Bool = false    // Send "stayed within limits" message

    init(
        notifyOnLimitExceeded: Bool = true,
        notifyOnIntegrityEvents: Bool = true,
        includeAppNames: Bool = false,
        includeTimeSpent: Bool = false,
        notifyOnDailySuccess: Bool = false
    ) {
        self.notifyOnLimitExceeded = notifyOnLimitExceeded
        self.notifyOnIntegrityEvents = notifyOnIntegrityEvents
        self.includeAppNames = includeAppNames
        self.includeTimeSpent = includeTimeSpent
        self.notifyOnDailySuccess = notifyOnDailySuccess
    }
}

// MARK: - Quiet Hours

struct QuietHours: Codable {
    var startHour: Int = 22    // 10 PM
    var endHour: Int = 8       // 8 AM
    var isEnabled: Bool = true

    init(startHour: Int = 22, endHour: Int = 8, isEnabled: Bool = true) {
        self.startHour = startHour
        self.endHour = endHour
        self.isEnabled = isEnabled
    }

    func isCurrentlyQuiet() -> Bool {
        guard isEnabled else { return false }
        let hour = Calendar.current.component(.hour, from: Date())

        if startHour > endHour {
            // Quiet hours span midnight (e.g., 10 PM - 8 AM)
            return hour >= startHour || hour < endHour
        } else {
            // Quiet hours within same day
            return hour >= startHour && hour < endHour
        }
    }

    var displayString: String {
        let startFormatted = String(format: "%d:00 %@", startHour % 12 == 0 ? 12 : startHour % 12, startHour >= 12 ? "PM" : "AM")
        let endFormatted = String(format: "%d:00 %@", endHour % 12 == 0 ? 12 : endHour % 12, endHour >= 12 ? "PM" : "AM")
        return "\(startFormatted) - \(endFormatted)"
    }
}
