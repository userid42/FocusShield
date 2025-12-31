import SwiftUI

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    var subtitle: String = ""
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticPattern.impact()
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.focusPrimary.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.focusPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.labelLarge)
                        .foregroundColor(.primary)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.labelSmall)
                            .foregroundColor(.neutral)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.neutral)
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        QuickActionButton(
            icon: "shield.fill",
            title: "Focus Block",
            subtitle: "1 hour"
        ) {
            print("Tapped")
        }

        QuickActionButton(
            icon: "gear",
            title: "Edit Limits"
        ) {
            print("Tapped")
        }
    }
    .padding()
    .background(Color.backgroundStart)
}
