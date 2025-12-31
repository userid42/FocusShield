import SwiftUI

// MARK: - Color System

extension Color {
    // Primary Brand Colors
    static let focusPrimary = Color(hex: "4F46E5")      // Indigo - trust, focus
    static let focusSecondary = Color(hex: "7C3AED")   // Violet - calm energy

    // Semantic Colors
    static let success = Color(hex: "10B981")          // Emerald - wins, streaks
    static let warning = Color(hex: "F59E0B")          // Amber - approaching limit
    static let danger = Color(hex: "EF4444")           // Red - limit exceeded
    static let neutral = Color(hex: "6B7280")          // Gray - secondary text

    // MARK: - Adaptive Colors (Light/Dark Mode)

    /// Background start color - adapts to color scheme
    static var adaptiveBackgroundStart: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "0F172A"))  // Slate 900
                : UIColor(Color(hex: "F8FAFC"))  // Slate 50
        })
    }

    /// Background end color - adapts to color scheme
    static var adaptiveBackgroundEnd: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "1E293B"))  // Slate 800
                : UIColor(Color(hex: "F1F5F9"))  // Slate 100
        })
    }

    /// Card background color - adapts to color scheme
    static var adaptiveCardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "1E293B"))  // Slate 800
                : UIColor.white
        })
    }

    /// Surface color for elevated elements - adapts to color scheme
    static var adaptiveSurface: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "334155"))  // Slate 700
                : UIColor.white
        })
    }

    /// Primary text color - adapts to color scheme
    static var adaptiveText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(Color(hex: "1E293B"))  // Slate 800
        })
    }

    /// Secondary text color - adapts to color scheme
    static var adaptiveSecondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "94A3B8"))  // Slate 400
                : UIColor(Color(hex: "6B7280"))  // Gray 500
        })
    }

    // MARK: - Legacy Static Colors (for backward compatibility)

    // Background Gradients (light mode - prefer adaptive versions)
    static let backgroundStart = Color(hex: "F8FAFC")  // Slate 50
    static let backgroundEnd = Color(hex: "F1F5F9")    // Slate 100

    // Dark Mode specific colors
    static let darkBackground = Color(hex: "0F172A")   // Slate 900
    static let darkSurface = Color(hex: "1E293B")      // Slate 800
    static let darkCard = Color(hex: "334155")         // Slate 700

    // Card/Surface (prefer adaptiveCardBackground)
    static let cardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(Color(hex: "1E293B"))
            : UIColor.white
    })
    static let cardBackgroundDark = Color(hex: "1E293B")

    // Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Presets

extension LinearGradient {
    static let primaryGradient = LinearGradient(
        colors: [Color.focusPrimary, Color.focusSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Adaptive background gradient that works in both light and dark mode
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.adaptiveBackgroundStart, Color.adaptiveBackgroundEnd],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static let successGradient = LinearGradient(
        colors: [Color.success, Color.success.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let dangerGradient = LinearGradient(
        colors: [Color.danger, Color.danger.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
