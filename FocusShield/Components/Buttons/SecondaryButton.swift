import SwiftUI

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false

    private var foregroundColor: Color {
        isDestructive ? .danger : .focusPrimary
    }

    var body: some View {
        Button(action: {
            HapticPattern.selection()
            action()
        }) {
            Text(title)
                .font(.labelLarge)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.clear)
                .foregroundColor(foregroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .stroke(foregroundColor, lineWidth: 1.5)
                )
        }
    }
}

// MARK: - Text Button

struct TextButton: View {
    let title: String
    let action: () -> Void
    var color: Color = .neutral

    var body: some View {
        Button(action: {
            HapticPattern.selection()
            action()
        }) {
            Text(title)
                .font(.labelLarge)
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        SecondaryButton(title: "Secondary Action") {
            print("Tapped")
        }

        SecondaryButton(title: "Delete", action: {}, isDestructive: true)

        TextButton(title: "Skip for now") {
            print("Skipped")
        }
    }
    .padding()
}
