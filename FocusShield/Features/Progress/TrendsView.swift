import SwiftUI

struct TrendsView: View {
    @EnvironmentObject var persistence: PersistenceService

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Screen time trend
                TrendCard(
                    title: "Screen Time",
                    icon: "clock.fill",
                    currentValue: "2h 15m",
                    changePercent: -12,
                    isPositive: true
                )
                .padding(.horizontal, Spacing.md)

                // Success rate trend
                TrendCard(
                    title: "Success Rate",
                    icon: "chart.line.uptrend.xyaxis",
                    currentValue: "78%",
                    changePercent: 8,
                    isPositive: true
                )
                .padding(.horizontal, Spacing.md)

                // I'm Done choices
                TrendCard(
                    title: "Good Choices",
                    icon: "checkmark.circle.fill",
                    currentValue: "24",
                    changePercent: 15,
                    isPositive: true
                )
                .padding(.horizontal, Spacing.md)

                // Emergency access
                TrendCard(
                    title: "Emergency Access",
                    icon: "exclamationmark.triangle.fill",
                    currentValue: "2",
                    changePercent: -50,
                    isPositive: true
                )
                .padding(.horizontal, Spacing.md)
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.backgroundStart.ignoresSafeArea())
        .navigationTitle("Trends")
    }
}

// MARK: - Trend Card

struct TrendCard: View {
    let title: String
    let icon: String
    let currentValue: String
    let changePercent: Int
    let isPositive: Bool

    private var changeColor: Color {
        isPositive ? .success : .danger
    }

    private var changeIcon: String {
        changePercent >= 0 ? "arrow.up.right" : "arrow.down.right"
    }

    var body: some View {
        FocusCard {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: icon)
                            .foregroundColor(.focusPrimary)
                        Text(title)
                            .font(.labelMedium)
                            .foregroundColor(.neutral)
                    }

                    Text(currentValue)
                        .font(.displayMedium)
                }

                Spacer()

                // Change indicator
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: changeIcon)
                        .font(.system(size: 12, weight: .bold))

                    Text("\(abs(changePercent))%")
                        .font(.labelLarge)
                }
                .foregroundColor(changeColor)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(changeColor.opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    NavigationStack {
        TrendsView()
            .environmentObject(PersistenceService.shared)
    }
}
