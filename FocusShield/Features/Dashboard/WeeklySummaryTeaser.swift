import SwiftUI

struct WeeklySummaryTeaser: View {
    let daysWithinLimits: Int
    let totalDays: Int

    private var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(daysWithinLimits) / Double(totalDays)
    }

    var body: some View {
        FocusCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("This Week")
                        .font(.headlineMedium)

                    Spacer()

                    NavigationLink {
                        WeeklyReviewView()
                    } label: {
                        Text("See details")
                            .font(.labelMedium)
                            .foregroundColor(.focusPrimary)
                    }
                }

                HStack(spacing: Spacing.lg) {
                    // Days within limits
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(daysWithinLimits)")
                                .font(.timerSmall)
                                .fontWeight(.semibold)
                                .foregroundColor(.focusPrimary)

                            Text("/ \(totalDays)")
                                .font(.bodyMedium)
                                .foregroundColor(.neutral)
                        }

                        Text("days within limits")
                            .font(.labelSmall)
                            .foregroundColor(.neutral)
                    }

                    Spacer()

                    // Progress ring
                    CircularProgressView(
                        progress: progress,
                        color: progress >= 0.7 ? .success : .focusPrimary,
                        lineWidth: 6
                    )
                    .frame(width: 50, height: 50)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        WeeklySummaryTeaser(daysWithinLimits: 5, totalDays: 7)
        WeeklySummaryTeaser(daysWithinLimits: 2, totalDays: 7)
    }
    .padding()
    .background(Color.backgroundStart)
}
