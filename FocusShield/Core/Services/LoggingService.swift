import Foundation
import OSLog

// MARK: - Logging Service

/// Centralized logging service for the app
/// Uses os_log for structured logging with proper levels
@MainActor
final class LoggingService {
    static let shared = LoggingService()

    private let logger: Logger

    private init() {
        logger = Logger(subsystem: "com.focusshield.app", category: "general")
    }

    // MARK: - Public Methods

    /// Log informational messages
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.info("\(message) [\(sourceLocation(file: file, function: function, line: line))]")
    }

    /// Log debug messages (only in debug builds)
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        logger.debug("\(message) [\(sourceLocation(file: file, function: function, line: line))]")
        #endif
    }

    /// Log warnings
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.warning("\(message) [\(sourceLocation(file: file, function: function, line: line))]")
    }

    /// Log errors
    func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let errorDetail = error.map { " Error: \($0.localizedDescription)" } ?? ""
        logger.error("\(message)\(errorDetail) [\(sourceLocation(file: file, function: function, line: line))]")
    }

    /// Log critical errors that require immediate attention
    func critical(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let errorDetail = error.map { " Error: \($0.localizedDescription)" } ?? ""
        logger.critical("\(message)\(errorDetail) [\(sourceLocation(file: file, function: function, line: line))]")
    }

    // MARK: - Domain-Specific Loggers

    /// Log keychain operations
    func keychain(_ message: String, operation: KeychainOperation, error: Error? = nil) {
        let opString = operation.rawValue
        if let error = error {
            logger.error("Keychain[\(opString)]: \(message) - \(error.localizedDescription)")
        } else {
            logger.debug("Keychain[\(opString)]: \(message)")
        }
    }

    /// Log persistence operations
    func persistence(_ message: String, operation: PersistenceOperation, error: Error? = nil) {
        let opString = operation.rawValue
        if let error = error {
            logger.error("Persistence[\(opString)]: \(message) - \(error.localizedDescription)")
        } else {
            logger.debug("Persistence[\(opString)]: \(message)")
        }
    }

    /// Log screen time service operations
    func screenTime(_ message: String, error: Error? = nil) {
        if let error = error {
            logger.error("ScreenTime: \(message) - \(error.localizedDescription)")
        } else {
            logger.debug("ScreenTime: \(message)")
        }
    }

    /// Log analytics events
    func analytics(_ event: String, parameters: [String: Any]? = nil) {
        let params = parameters.map { " Params: \($0)" } ?? ""
        logger.info("Analytics: \(event)\(params)")
    }

    // MARK: - Private Helpers

    private func sourceLocation(file: String, function: String, line: Int) -> String {
        let filename = (file as NSString).lastPathComponent
        return "\(filename):\(line) \(function)"
    }
}

// MARK: - Operation Types

enum KeychainOperation: String {
    case save = "Save"
    case load = "Load"
    case delete = "Delete"
    case deleteAll = "DeleteAll"
}

enum PersistenceOperation: String {
    case save = "Save"
    case load = "Load"
    case delete = "Delete"
    case encode = "Encode"
    case decode = "Decode"
}

// MARK: - Convenience Shortcuts

extension LoggingService {
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.info(message, file: file, function: function, line: line)
    }

    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.debug(message, file: file, function: function, line: line)
    }

    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.warning(message, file: file, function: function, line: line)
    }

    static func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        shared.error(message, error: error, file: file, function: function, line: line)
    }

    static func critical(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        shared.critical(message, error: error, file: file, function: function, line: line)
    }
}
