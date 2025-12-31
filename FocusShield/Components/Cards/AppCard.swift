import SwiftUI

// MARK: - App Card

struct AppCard: View {
    let name: String
    var icon: String? = nil
    var usedMinutes: Int = 0
    var limitMinutes: Int = 30
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    private var progress: Double {
        guard limitMinutes > 0 else { return 0 }
        return Double(usedMinutes) / Double(limitMinutes)
    }

    private var statusColor: Color {
        if progress >= 1.0 { return .danger }
        if progress >= 0.8 { return .warning }
        return .focusPrimary
    }

    var body: some View {
        Button {
            HapticPattern.selection()
            onTap?()
        } label: {
            HStack(spacing: Spacing.sm) {
                // App icon placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.neutral.opacity(0.1))
                        .frame(width: 44, height: 44)

                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(.neutral)
                    } else {
                        Image(systemName: "app.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.neutral)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.bodyLarge)
                        .foregroundColor(.primary)

                    HStack(spacing: Spacing.xs) {
                        Text("\(usedMinutes)m / \(limitMinutes)m")
                            .font(.labelSmall)
                            .foregroundColor(.neutral)

                        if progress >= 1.0 {
                            Text("Exceeded")
                                .font(.labelSmall)
                                .foregroundColor(.danger)
                        }
                    }
                }

                Spacer()

                // Progress indicator or selection
                if let _ = onTap {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.focusPrimary)
                            .font(.system(size: 24))
                    } else {
                        Circle()
                            .stroke(Color.neutral.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                } else {
                    CircularProgressView(progress: progress, color: statusColor)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(Spacing.sm)
            .background(isSelected ? Color.focusPrimary.opacity(0.05) : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(isSelected ? Color.focusPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Circular Progress View

struct CircularProgressView: View {
    let progress: Double
    var color: Color = .focusPrimary
    var lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.neutral.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.sm) {
        AppCard(
            name: "Instagram",
            icon: "camera.fill",
            usedMinutes: 20,
            limitMinutes: 30
        )

        AppCard(
            name: "TikTok",
            icon: "play.rectangle.fill",
            usedMinutes: 15,
            limitMinutes: 15
        )

        AppCard(
            name: "Twitter",
            icon: "bubble.left.fill",
            usedMinutes: 10,
            limitMinutes: 30,
            isSelected: true
        ) {
            print("Selected")
        }
    }
    .padding()
    .background(Color.backgroundStart)
}
