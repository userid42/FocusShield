import Foundation

// MARK: - Input Validation

/// Utility for validating user inputs
enum Validation {

    // MARK: - Email Validation

    /// Validates an email address using RFC 5322 compliant regex
    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        // RFC 5322 compliant email regex
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#

        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: trimmed)
    }

    // MARK: - Phone Validation

    /// Validates a phone number (supports various international formats)
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        // Remove common formatting characters
        let digits = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        // Must have at least 10 digits (US) and at most 15 (international max)
        guard digits.count >= 10 && digits.count <= 15 else { return false }

        return true
    }

    /// Formats a phone number for display
    static func formatPhoneNumber(_ phone: String) -> String {
        let digits = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        // Format as US number if 10 digits
        if digits.count == 10 {
            let areaCode = digits.prefix(3)
            let prefix = digits.dropFirst(3).prefix(3)
            let suffix = digits.suffix(4)
            return "(\(areaCode)) \(prefix)-\(suffix)"
        }

        // Format as international if starts with 1 and has 11 digits
        if digits.count == 11 && digits.hasPrefix("1") {
            let withoutCountry = String(digits.dropFirst())
            let areaCode = withoutCountry.prefix(3)
            let prefix = withoutCountry.dropFirst(3).prefix(3)
            let suffix = withoutCountry.suffix(4)
            return "+1 (\(areaCode)) \(prefix)-\(suffix)"
        }

        // Return as-is with + prefix for other international numbers
        return "+\(digits)"
    }

    // MARK: - Sanitization

    /// Sanitizes a string by removing potentially dangerous characters
    static func sanitize(_ input: String) -> String {
        // Remove control characters and null bytes
        var sanitized = input.components(separatedBy: CharacterSet.controlCharacters).joined()

        // Trim whitespace
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)

        // Limit length to prevent buffer overflow attacks
        if sanitized.count > 500 {
            sanitized = String(sanitized.prefix(500))
        }

        return sanitized
    }

    /// Sanitizes an email address
    static func sanitizeEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Sanitizes a phone number (keeps only digits and leading +)
    static func sanitizePhoneNumber(_ phone: String) -> String {
        var result = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        let hasPlus = result.hasPrefix("+")
        let digits = result.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        return hasPlus ? "+\(digits)" : digits
    }

    // MARK: - Name Validation

    /// Validates a person's name
    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // Must be at least 1 character
        guard !trimmed.isEmpty else { return false }

        // Must not exceed reasonable length
        guard trimmed.count <= 100 else { return false }

        // Should contain at least one letter
        let letters = CharacterSet.letters
        guard trimmed.unicodeScalars.contains(where: { letters.contains($0) }) else {
            return false
        }

        return true
    }
}

// MARK: - Validation Result

enum ValidationResult {
    case valid
    case invalid(message: String)

    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}

// MARK: - Contact Validation

extension Validation {
    /// Validates contact information and returns a detailed result
    static func validateContact(_ contact: String, type: ContactType) -> ValidationResult {
        let sanitized = contact.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !sanitized.isEmpty else {
            return .invalid(message: "Contact information is required")
        }

        switch type {
        case .email:
            if isValidEmail(sanitized) {
                return .valid
            } else {
                return .invalid(message: "Please enter a valid email address")
            }

        case .phone:
            if isValidPhoneNumber(sanitized) {
                return .valid
            } else {
                return .invalid(message: "Please enter a valid phone number (10+ digits)")
            }

        case .auto:
            // Auto-detect type based on content
            if sanitized.contains("@") {
                return validateContact(sanitized, type: .email)
            } else {
                return validateContact(sanitized, type: .phone)
            }
        }
    }

    enum ContactType {
        case email
        case phone
        case auto
    }
}
