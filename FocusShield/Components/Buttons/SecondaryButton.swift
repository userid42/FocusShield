import SwiftUI

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var isDestructive: Bool = false
    var isDisabled: Bool = false
    var accessibilityHint: String? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    private var foregroundColor: Color {
        if isDisabled { return .neutral.opacity(0.5) }
        return isDestructive ? .danger : .focusPrimary
    }

    var body: some View {
        Button(action: {
            guard !isDisabled else { return }
            HapticPattern.selection()
            action()
        }) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.labelLarge)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)  // Accessibility touch target
            .padding(.vertical, Spacing.sm)
            .background(foregroundColor.opacity(isPressed ? 0.08 : 0))
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(foregroundColor, lineWidth: 1.5)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(reduceMotion ? .none : .spring(response: 0.2), value: isPressed)
        }
        .buttonStyle(SecondaryPressableStyle(isPressed: $isPressed))
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Secondary Pressable Style

private struct SecondaryPressableStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Text Button

struct TextButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var color: Color = .neutral
    var accessibilityHint: String? = nil

    var body: some View {
        Button(action: {
            HapticPattern.selection()
            action()
        }) {
            HStack(spacing: Spacing.xxs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.labelLarge)
            }
            .foregroundColor(color)
            .padding(.vertical, Spacing.xs)
            .padding(.horizontal, Spacing.sm)
        }
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        SecondaryButton(title: "Secondary Action") {
            print("Tapped")
        }

        SecondaryButton(title: "With Icon", action: {}, icon: "arrow.clockwise")

        SecondaryButton(title: "Delete", action: {}, isDestructive: true)

        SecondaryButton(title: "Disabled", action: {}, isDisabled: true)

        TextButton(title: "Skip for now") {
            print("Skipped")
        }

        TextButton(title: "Learn more", action: {}, icon: "info.circle", color: .focusPrimary)
    }
    .padding()
}
