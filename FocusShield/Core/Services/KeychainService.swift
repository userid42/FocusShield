import Foundation
import Security

// MARK: - Keychain Service

/// Secure storage service for sensitive data using iOS Keychain
/// Use this for storing contact information, tokens, and other sensitive user data
/// Reference: iOS Security Best Practices - https://developer.apple.com/documentation/security/keychain_services
@MainActor
final class KeychainService {
    static let shared = KeychainService()

    private let serviceName = "com.focusshield.keychain"
    private let accessGroup: String? = nil // Use app group if needed for sharing with extensions

    private init() {}

    // MARK: - Error Types

    enum KeychainError: LocalizedError {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case encodingFailed
        case decodingFailed

        var errorDescription: String? {
            switch self {
            case .duplicateItem:
                return "Item already exists in keychain"
            case .itemNotFound:
                return "Item not found in keychain"
            case .unexpectedStatus(let status):
                return "Keychain error: \(status)"
            case .encodingFailed:
                return "Failed to encode data for keychain"
            case .decodingFailed:
                return "Failed to decode data from keychain"
            }
        }
    }

    // MARK: - Keys

    enum Key: String {
        case partnerContactEmail = "partner_contact_email"
        case partnerContactPhone = "partner_contact_phone"
        case partnerDeviceToken = "partner_device_token"
        case userAuthToken = "user_auth_token"
    }

    // MARK: - Public Methods

    /// Save a string value to the keychain
    func save(_ value: String, forKey key: Key) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        try save(data, forKey: key.rawValue)
    }

    /// Retrieve a string value from the keychain
    func getString(forKey key: Key) throws -> String? {
        guard let data = try getData(forKey: key.rawValue) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Save a Codable object to the keychain
    func save<T: Encodable>(_ value: T, forKey key: Key) throws {
        let data = try JSONEncoder().encode(value)
        try save(data, forKey: key.rawValue)
    }

    /// Retrieve a Codable object from the keychain
    func get<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
        guard let data = try getData(forKey: key.rawValue) else {
            return nil
        }
        return try JSONDecoder().decode(type, from: data)
    }

    /// Delete a value from the keychain
    func delete(forKey key: Key) throws {
        try delete(forKey: key.rawValue)
    }

    /// Check if a key exists in the keychain
    func exists(forKey key: Key) -> Bool {
        do {
            return try getData(forKey: key.rawValue) != nil
        } catch {
            return false
        }
    }

    /// Delete all keychain items for this service
    func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Private Methods

    private func save(_ data: Data, forKey key: String) throws {
        // First try to delete existing item
        try? delete(forKey: key)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateItem
            }
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func getData(forKey key: String) throws -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        return result as? Data
    }

    private func delete(forKey key: String) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

// MARK: - Secure Contact Storage Extension

extension KeychainService {
    /// Securely store contact information for accountability partner
    func saveContactMethod(_ contact: ContactMethod) throws {
        switch contact {
        case .email(let address):
            try save(address, forKey: .partnerContactEmail)
            try? delete(forKey: .partnerContactPhone)
            try? delete(forKey: .partnerDeviceToken)
        case .sms(let phoneNumber):
            try save(phoneNumber, forKey: .partnerContactPhone)
            try? delete(forKey: .partnerContactEmail)
            try? delete(forKey: .partnerDeviceToken)
        case .pushNotification(let deviceToken):
            try save(deviceToken, forKey: .partnerDeviceToken)
            try? delete(forKey: .partnerContactEmail)
            try? delete(forKey: .partnerContactPhone)
        }
    }

    /// Retrieve contact method from secure storage
    func getContactMethod() -> ContactMethod? {
        do {
            if let email = try getString(forKey: .partnerContactEmail) {
                return .email(address: email)
            }
            if let phone = try getString(forKey: .partnerContactPhone) {
                return .sms(phoneNumber: phone)
            }
            if let token = try getString(forKey: .partnerDeviceToken) {
                return .pushNotification(deviceToken: token)
            }
        } catch {
            LoggingService.shared.keychain(
                "Failed to retrieve contact method",
                operation: .load,
                error: error
            )
        }
        return nil
    }

    /// Clear all contact information
    func clearContactMethod() {
        try? delete(forKey: .partnerContactEmail)
        try? delete(forKey: .partnerContactPhone)
        try? delete(forKey: .partnerDeviceToken)
    }
}
