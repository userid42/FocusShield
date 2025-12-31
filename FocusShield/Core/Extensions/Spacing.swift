import SwiftUI

// MARK: - Spacing System (8pt grid)

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius

enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999  // Pill shape
}

// MARK: - Shadow Presets

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let subtle = ShadowStyle(
        color: .black.opacity(0.04),
        radius: 8,
        x: 0,
        y: 2
    )

    static let medium = ShadowStyle(
        color: .black.opacity(0.08),
        radius: 12,
        x: 0,
        y: 4
    )

    static let strong = ShadowStyle(
        color: .black.opacity(0.12),
        radius: 20,
        x: 0,
        y: 8
    )
}

extension View {
    func cardShadow(_ style: ShadowStyle = .subtle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
