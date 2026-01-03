import SwiftUI

// MARK: - Progress Bar

struct ProgressBar: View {
    let progress: Double
    var color: Color = .focusPrimary
    var backgroundColor: Color = .neutral.opacity(0.2)
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)

                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Labeled Progress Bar

struct LabeledProgressBar: View {
    let title: String
    let progress: Double
    var showPercentage: Bool = true
    var color: Color = .focusPrimary

    private var progressColor: Color {
        if progress >= 1.0 { return .danger }
        if progress >= 0.8 { return .warning }
        return color
    }

    private var accessibilityLabel: String {
        let percent = Int(progress * 100)
        var status = ""
        if progress >= 1.0 {
            status = ", limit exceeded"
        } else if progress >= 0.8 {
            status = ", approaching limit"
        }
        return "\(title), \(percent) percent\(status)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(title)
                    .font(.labelMedium)
                    .foregroundColor(.primary)

                Spacer()

                if showPercentage {
                    Text("\(Int(progress * 100))%")
                        .font(.labelMedium)
                        .foregroundColor(.neutral)
                }
            }

            ProgressBar(progress: progress, color: progressColor)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Week Progress

struct WeekProgressView: View {
    let records: [DailyRecord]

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(Weekday.allCases) { day in
                DayProgressDot(
                    day: day,
                    status: statusForDay(day)
                )
            }
        }
    }

    private func statusForDay(_ day: Weekday) -> DayStatus {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())

        if day.rawValue > today {
            return .future
        }

        if let record = records.first(where: {
            calendar.component(.weekday, from: $0.date) == day.rawValue
        }) {
            return record.withinAllLimits ? .success : .failed
        }

        return day.rawValue == today ? .inProgress : .missed
    }
}

// MARK: - Day Progress Dot

struct DayProgressDot: View {
    let day: Weekday
    let status: DayStatus

    private var accessibilityLabel: String {
        let statusText: String
        switch status {
        case .success: statusText = "success, within limits"
        case .failed: statusText = "failed, exceeded limits"
        case .inProgress: statusText = "in progress"
        case .future: statusText = "future day"
        case .missed: statusText = "no data"
        }
        return "\(day.rawValue), \(statusText)"
    }

    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Circle()
                .fill(status.color)
                .frame(width: 32, height: 32)
                .overlay {
                    if status == .success {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .accessibilityHidden(true)
                    } else if status == .failed {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .accessibilityHidden(true)
                    }
                }

            Text(day.letter)
                .font(.labelSmall)
                .foregroundColor(.neutral)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

enum DayStatus {
    case success
    case failed
    case inProgress
    case future
    case missed

    var color: Color {
        switch self {
        case .success: return .success
        case .failed: return .danger
        case .inProgress: return .focusPrimary
        case .future: return .neutral.opacity(0.2)
        case .missed: return .neutral.opacity(0.3)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        ProgressBar(progress: 0.6)

        LabeledProgressBar(
            title: "Daily Progress",
            progress: 0.75
        )

        LabeledProgressBar(
            title: "Almost exceeded",
            progress: 0.9
        )

        WeekProgressView(records: [])
    }
    .padding()
    .background(Color.backgroundStart)
}
