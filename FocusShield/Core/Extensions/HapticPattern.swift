import UIKit

// MARK: - Haptic Feedback Patterns

/// Provides haptic feedback patterns that respect user preferences
/// Haptics can be disabled in Settings > Appearance & Feedback
enum HapticPattern {

    /// Check if haptics are enabled in user settings
    private static var isEnabled: Bool {
        // Access UserDefaults directly to avoid circular dependency with PersistenceService
        if let data = UserDefaults.appGroup.data(forKey: "appSettings"),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            return settings.hapticsEnabled
        }
        return true // Default to enabled
    }

    static func success() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    static func error() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    static func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func lightImpact() {
        impact(style: .light)
    }

    static func heavyImpact() {
        impact(style: .heavy)
    }

    static func softImpact() {
        impact(style: .soft)
    }

    static func rigidImpact() {
        impact(style: .rigid)
    }
}
