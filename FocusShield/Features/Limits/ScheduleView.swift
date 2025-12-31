import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var persistence: PersistenceService
    @State private var showingAddWindow = false

    var body: some View {
        List {
            if persistence.timeWindows.isEmpty {
                Section {
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(.neutral.opacity(0.5))

                        Text("No schedules yet")
                            .font(.headlineMedium)

                        Text("Create time windows to automatically block apps during specific hours.")
                            .font(.bodySmall)
                            .foregroundColor(.neutral)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.xl)
                }
            } else {
                ForEach(persistence.timeWindows) { window in
                    TimeWindowRow(window: window)
                }
                .onDelete(perform: deleteWindow)
            }
        }
        .navigationTitle("Schedules")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddWindow = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddWindow) {
            AddTimeWindowView { window in
                persistence.addTimeWindow(window)
            }
        }
    }

    private func deleteWindow(at offsets: IndexSet) {
        for index in offsets {
            let window = persistence.timeWindows[index]
            persistence.removeTimeWindow(id: window.id)
        }
    }
}

// MARK: - Time Window Row

struct TimeWindowRow: View {
    let window: TimeWindow

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(window.name.isEmpty ? "Schedule" : window.name)
                    .font(.headlineMedium)

                Text(window.displayTimeRange)
                    .font(.labelMedium)
                    .foregroundColor(.neutral)

                Text(window.displayDays)
                    .font(.labelSmall)
                    .foregroundColor(.neutral)
            }

            Spacer()

            Circle()
                .fill(window.isEnabled ? Color.success : Color.neutral.opacity(0.3))
                .frame(width: 10, height: 10)
        }
    }
}

// MARK: - Add Time Window View

struct AddTimeWindowView: View {
    let onSave: (TimeWindow) -> Void

    @State private var name: String = ""
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var selectedDays: Set<Int> = Set(1...7)

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Schedule name", text: $name)
                } header: {
                    Text("Name")
                }

                Section {
                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                } header: {
                    Text("Time")
                }

                Section {
                    HStack {
                        ForEach(Weekday.allCases) { day in
                            Button {
                                if selectedDays.contains(day.rawValue) {
                                    selectedDays.remove(day.rawValue)
                                } else {
                                    selectedDays.insert(day.rawValue)
                                }
                            } label: {
                                Text(day.letter)
                                    .font(.labelMedium)
                                    .frame(width: 36, height: 36)
                                    .background(selectedDays.contains(day.rawValue) ? Color.focusPrimary : Color.neutral.opacity(0.1))
                                    .foregroundColor(selectedDays.contains(day.rawValue) ? .white : .primary)
                                    .clipShape(Circle())
                            }
                        }
                    }
                } header: {
                    Text("Days")
                }
            }
            .navigationTitle("New Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWindow()
                    }
                    .disabled(selectedDays.isEmpty)
                }
            }
        }
    }

    private func saveWindow() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        let window = TimeWindow(
            name: name,
            startTime: startComponents,
            endTime: endComponents,
            activeDays: selectedDays
        )

        onSave(window)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ScheduleView()
            .environmentObject(PersistenceService.shared)
    }
}
