import SwiftUI

// MARK: - Budget Ring

struct BudgetRing: View {
    let progress: Double  // 0.0 to 1.0
    let appName: String
    let usedMinutes: Int
    let totalMinutes: Int
    var size: CGFloat = 80

    private var ringColor: Color {
        if progress >= 1.0 { return .danger }
        if progress >= 0.8 { return .warning }
        return .focusPrimary
    }

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.neutral.opacity(0.2), lineWidth: 8)

                // Progress ring
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: progress)

                // Center content
                VStack(spacing: 2) {
                    Text("\(usedMinutes)")
                        .font(.timerSmall)
                        .fontWeight(.semibold)
                    Text("/ \(totalMinutes)m")
                        .font(.labelSmall)
                        .foregroundColor(.neutral)
                }
            }
            .frame(width: size, height: size)

            Text(appName)
                .font(.labelMedium)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
}

// MARK: - Large Budget Ring

struct LargeBudgetRing: View {
    let progress: Double
    let usedMinutes: Int
    let totalMinutes: Int
    let title: String

    private var ringColor: Color {
        if progress >= 1.0 { return .danger }
        if progress >= 0.8 { return .warning }
        return .focusPrimary
    }

    private var statusText: String {
        if progress >= 1.0 { return "Exceeded" }
        if progress >= 0.8 { return "Almost there" }
        return "On track"
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.neutral.opacity(0.15), lineWidth: 16)

                // Progress ring
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: progress)

                // Center content
                VStack(spacing: Spacing.xs) {
                    Text("\(usedMinutes)")
                        .font(.timer)
                        .fontWeight(.medium)

                    Text("of \(totalMinutes) min")
                        .font(.bodyMedium)
                        .foregroundColor(.neutral)

                    Text(statusText)
                        .font(.labelMedium)
                        .foregroundColor(ringColor)
                }
            }
            .frame(width: 200, height: 200)

            Text(title)
                .font(.headlineMedium)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.xl) {
        HStack(spacing: Spacing.lg) {
            BudgetRing(
                progress: 0.5,
                appName: "Social",
                usedMinutes: 15,
                totalMinutes: 30
            )

            BudgetRing(
                progress: 0.85,
                appName: "TikTok",
                usedMinutes: 13,
                totalMinutes: 15
            )

            BudgetRing(
                progress: 1.0,
                appName: "Games",
                usedMinutes: 35,
                totalMinutes: 30
            )
        }

        LargeBudgetRing(
            progress: 0.6,
            usedMinutes: 45,
            totalMinutes: 75,
            title: "Total Screen Time"
        )
    }
    .padding()
    .background(Color.backgroundStart)
}
