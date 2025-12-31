import SwiftUI

struct StreakView: View {
    @EnvironmentObject var persistence: PersistenceService
    @State private var showingResetRitual = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Large streak display
                LargeStreakDisplay(
                    currentStreak: persistence.userProgress.currentStreak,
                    longestStreak: persistence.userProgress.longestStreak
                )

                // Streak calendar
                StreakCalendarView(records: persistence.userProgress.weeklyHistory)
                    .padding(.horizontal, Spacing.md)

                // Motivation quote
                MotivationCard()
                    .padding(.horizontal, Spacing.md)

                // Reset ritual button (if streak is 0)
                if persistence.userProgress.currentStreak == 0 {
                    Button {
                        showingResetRitual = true
                    } label: {
                        Text("Start Fresh")
                            .font(.labelLarge)
                            .foregroundColor(.focusPrimary)
                    }
                }
            }
            .padding(.vertical, Spacing.lg)
        }
        .background(Color.backgroundStart.ignoresSafeArea())
        .navigationTitle("Streak")
        .sheet(isPresented: $showingResetRitual) {
            StreakResetRitualView()
        }
    }
}

// MARK: - Streak Calendar View

struct StreakCalendarView: View {
    let records: [DailyRecord]

    var body: some View {
        FocusCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Last 7 Days")
                    .font(.headlineMedium)

                HStack(spacing: Spacing.sm) {
                    ForEach(records.suffix(7)) { record in
                        VStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(record.withinAllLimits ? Color.success : Color.danger)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    if record.withinAllLimits {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }

                            Text(record.shortDisplayDate)
                                .font(.labelSmall)
                                .foregroundColor(.neutral)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Motivation Card

struct MotivationCard: View {
    let quotes = [
        "Small steps every day lead to big changes.",
        "You're rewiring your brain, one choice at a time.",
        "The urge passes. You remain.",
        "Every 'no' to distraction is a 'yes' to your goals."
    ]

    var body: some View {
        FocusCard {
            VStack(spacing: Spacing.sm) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 24))
                    .foregroundColor(.focusPrimary.opacity(0.5))

                Text(quotes.randomElement() ?? quotes[0])
                    .font(.bodyLarge)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.neutral)
            }
        }
    }
}

// MARK: - Streak Reset Ritual View

struct StreakResetRitualView: View {
    @State private var selectedReason: StreakBreakReason?
    @State private var adjustment: String = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                Text("Streaks break.\nThat's normal.")
                    .font(.displayMedium)
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.xl)

                Text("What happened?")
                    .font(.headlineMedium)
                    .padding(.top, Spacing.md)

                VStack(spacing: Spacing.sm) {
                    ForEach(StreakBreakReason.allCases) { reason in
                        Button {
                            selectedReason = reason
                        } label: {
                            HStack {
                                Text(reason.rawValue)
                                    .font(.bodyLarge)
                                Spacer()
                                if selectedReason == reason {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.focusPrimary)
                                }
                            }
                            .padding(Spacing.md)
                            .background(
                                selectedReason == reason ?
                                Color.focusPrimary.opacity(0.1) : Color.cardBackground
                            )
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.md)

                if selectedReason != nil {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("What's one small thing you could adjust?")
                            .font(.labelMedium)
                            .foregroundColor(.neutral)

                        TextField("e.g., Put phone in another room at night", text: $adjustment)
                            .textFieldStyle(.plain)
                            .padding(Spacing.md)
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }
                    .padding(.horizontal, Spacing.md)
                    .transition(.fadeAndSlide)
                }

                Spacer()

                PrimaryButton(title: "Start Fresh") {
                    dismiss()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.lg)
            }
            .navigationTitle("Reset Ritual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .animation(.smooth, value: selectedReason)
        }
    }
}

#Preview {
    NavigationStack {
        StreakView()
            .environmentObject(PersistenceService.shared)
    }
}
