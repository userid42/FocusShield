import SwiftUI

// MARK: - Typography System

extension Font {
    // Display - Large headers, impact moments
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)

    // Headlines - Section headers
    static let headlineLarge = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 18, weight: .semibold, design: .rounded)

    // Body - Main content
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // Labels - Buttons, captions
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // Monospace - Timers, numbers
    static let timer = Font.system(size: 48, weight: .light, design: .monospaced)
    static let timerSmall = Font.system(size: 24, weight: .regular, design: .monospaced)
    static let timerMedium = Font.system(size: 32, weight: .medium, design: .monospaced)
}
