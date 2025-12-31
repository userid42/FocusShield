import UIKit

// MARK: - Haptic Feedback Patterns

enum HapticPattern {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
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
