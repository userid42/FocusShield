import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var accessibilityHint: String? = nil

    private var accessibilityLabel: String {
        if isLoading {
            return "\(title), loading"
        }
        return title
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
                    colors: isDisabled ? [Color.neutral.opacity(0.5)] : [Color.focusPrimary, Color.focusSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
        .disabled(isLoading || isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(isDisabled ? .isButton : [.isButton])
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        PrimaryButton(title: "Continue") {
            print("Tapped")
        }

        PrimaryButton(title: "Loading...", action: {}, isLoading: true)

        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}
