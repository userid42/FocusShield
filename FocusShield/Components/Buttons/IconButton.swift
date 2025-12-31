import SwiftUI

// MARK: - Icon Button

struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: IconButtonSize = .medium
    var style: IconButtonStyle = .filled

    var body: some View {
        Button(action: {
            HapticPattern.lightImpact()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(style.foregroundColor)
                .frame(width: size.buttonSize, height: size.buttonSize)
                .background(style.backgroundColor)
                .clipShape(Circle())
        }
    }
}

// MARK: - Icon Button Size

enum IconButtonSize {
    case small
    case medium
    case large

    var buttonSize: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 44
        case .large: return 56
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 18
        case .large: return 24
        }
    }
}

// MARK: - Icon Button Style

enum IconButtonStyle {
    case filled
    case outlined
    case ghost

    var backgroundColor: Color {
        switch self {
        case .filled: return Color.focusPrimary.opacity(0.1)
        case .outlined: return Color.clear
        case .ghost: return Color.clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .filled: return Color.focusPrimary
        case .outlined: return Color.focusPrimary
        case .ghost: return Color.neutral
        }
    }
}

// MARK: - Close Button

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticPattern.lightImpact()
            action()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.neutral.opacity(0.5))
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        HStack(spacing: Spacing.md) {
            IconButton(icon: "plus", action: {}, size: .small)
            IconButton(icon: "plus", action: {}, size: .medium)
            IconButton(icon: "plus", action: {}, size: .large)
        }

        HStack(spacing: Spacing.md) {
            IconButton(icon: "gear", action: {}, style: .filled)
            IconButton(icon: "gear", action: {}, style: .outlined)
            IconButton(icon: "gear", action: {}, style: .ghost)
        }

        CloseButton(action: {})
    }
    .padding()
}
