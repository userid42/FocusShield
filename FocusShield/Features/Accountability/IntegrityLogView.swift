import SwiftUI

struct IntegrityLogView: View {
    @EnvironmentObject var persistence: PersistenceService

    var body: some View {
        Group {
            if persistence.integrityEvents.isEmpty {
                EmptyStateView(
                    icon: "list.bullet.rectangle",
                    title: "No activity yet",
                    message: "Your activity log will appear here as events happen."
                )
            } else {
                List {
                    ForEach(groupedEvents.keys.sorted().reversed(), id: \.self) { date in
                        Section {
                            ForEach(groupedEvents[date] ?? []) { event in
                                IntegrityEventRow(event: event)
                            }
                        } header: {
                            Text(formatDate(date))
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Activity Log")
    }

    private var groupedEvents: [Date: [IntegrityEvent]] {
        Dictionary(grouping: persistence.integrityEvents) { event in
            Calendar.current.startOfDay(for: event.timestamp)
        }
    }

    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Integrity Event Row

struct IntegrityEventRow: View {
    let event: IntegrityEvent

    private var severityColor: Color {
        switch event.type.severity {
        case .low: return .success
        case .medium: return .neutral
        case .high: return .warning
        case .critical: return .danger
        }
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: event.type.icon)
                .font(.system(size: 18))
                .foregroundColor(severityColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.type.notificationMessage)
                    .font(.bodyMedium)

                HStack(spacing: Spacing.xs) {
                    Text(formatTime(event.timestamp))
                        .font(.labelSmall)
                        .foregroundColor(.neutral)

                    if let appName = event.appName {
                        Text(appName)
                            .font(.labelSmall)
                            .foregroundColor(.neutral)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.neutral.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    if event.wasNotified {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.neutral)
                    }
                }
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        IntegrityLogView()
            .environmentObject(PersistenceService.shared)
    }
}
