import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var isDestructive: Bool = false
    var accessibilityHint: String? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    private var accessibilityLabel: String {
        if isLoading {
            return "\(title), loading"
        }
        if isDisabled {
            return "\(title), disabled"
        }
        return title
    }

    private var buttonColors: [Color] {
        if isDisabled {
            return [Color.neutral.opacity(0.5), Color.neutral.opacity(0.4)]
        }
        if isDestructive {
            return [Color.danger, Color.danger.opacity(0.85)]
        }
        return [Color.focusPrimary, Color.focusSecondary]
    }

    var body: some View {
        Button(action: {
            guard !isLoading && !isDisabled else { return }
            HapticPattern.impact()
            action()
        }) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                        .accessibilityHidden(true)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .accessibilityHidden(true)
                }

                Text(title)
                    .font(.labelLarge)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)  // Ensure minimum touch target size for accessibility
            .padding(.vertical, Spacing.md)
            .background(
                LinearGradient(
                    colors: buttonColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(reduceMotion ? .none : .spring(response: 0.2), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        .disabled(isLoading || isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
        .accessibilityRemoveTraits(isDisabled ? .isButton : [])
    }
}

// MARK: - Pressable Button Style

private struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        PrimaryButton(title: "Continue", action: {})

        PrimaryButton(title: "With Icon", action: {}, icon: "arrow.right")

        PrimaryButton(title: "Loading...", action: {}, isLoading: true)

        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)

        PrimaryButton(title: "Delete", action: {}, isDestructive: true)
    }
    .padding()
}
