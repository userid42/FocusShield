import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: {
            HapticPattern.impact()
            action()
        }) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.labelLarge)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
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
