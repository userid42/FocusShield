import SwiftUI

struct CommitmentModeView: View {
    @EnvironmentObject var persistence: PersistenceService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: CommitmentMode
    @State private var showingConfirmation = false
    @State private var pendingMode: CommitmentMode?

    init() {
        _selectedMode = State(initialValue: PersistenceService.shared.user?.commitmentMode ?? .standard)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header explanation
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.focusPrimary)

                    Text("Choose Your Protection Level")
                        .font(.headlineLarge)
                        .multilineTextAlignment(.center)

                    Text("Higher commitment = stronger protection.\nChoose based on your current needs.")
                        .font(.bodyMedium)
                        .foregroundColor(.neutral)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, Spacing.lg)

                // Mode options
                VStack(spacing: Spacing.md) {
                    ForEach(CommitmentMode.allCases) { mode in
                        CommitmentModeCard(
                            mode: mode,
                            isSelected: selectedMode == mode
                        ) {
                            handleModeSelection(mode)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)

                // Current mode info
                if let currentMode = persistence.user?.commitmentMode,
                   currentMode != selectedMode {
                    CooldownInfoCard(
                        from: currentMode,
                        to: selectedMode
                    )
                    .padding(.horizontal, Spacing.md)
                }

                Spacer(minLength: Spacing.xl)
            }
        }
        .background(Color.backgroundStart.ignoresSafeArea())
        .navigationTitle("Commitment Mode")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Change Commitment Mode?", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) {
                pendingMode = nil
            }
            Button("Change") {
                if let mode = pendingMode {
                    applyModeChange(mode)
                }
            }
        } message: {
            if let mode = pendingMode {
                Text(confirmationMessage(for: mode))
            }
        }
    }

    private func handleModeSelection(_ mode: CommitmentMode) {
        let currentMode = persistence.user?.commitmentMode ?? .standard

        // Increasing strictness is immediate
        if mode.strictnessLevel > currentMode.strictnessLevel {
            pendingMode = mode
            showingConfirmation = true
        }
        // Decreasing strictness has cooldown
        else if mode.strictnessLevel < currentMode.strictnessLevel {
            pendingMode = mode
            showingConfirmation = true
        }
        // Same mode, do nothing
    }

    private func confirmationMessage(for mode: CommitmentMode) -> String {
        let currentMode = persistence.user?.commitmentMode ?? .standard

        if mode.strictnessLevel > currentMode.strictnessLevel {
            return "Switching to \(mode.rawValue) mode will increase your protection level. This change takes effect immediately."
        } else {
            return "Switching to \(mode.rawValue) mode will decrease your protection. A 24-hour cooldown will apply before the change takes effect."
        }
    }

    private func applyModeChange(_ mode: CommitmentMode) {
        persistence.updateCommitmentMode(mode)
        selectedMode = mode
        pendingMode = nil
        HapticPattern.success()
    }
}

// MARK: - Commitment Mode Card

struct CommitmentModeCard: View {
    let mode: CommitmentMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: mode.icon)
                                .foregroundColor(mode.color)
                            Text(mode.rawValue)
                                .font(.headlineMedium)
                        }

                        Text(mode.tagline)
                            .font(.labelMedium)
                            .foregroundColor(.neutral)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.focusPrimary)
                    } else {
                        Circle()
                            .stroke(Color.neutral.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }

                Divider()

                // Features list
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    ForEach(mode.features, id: \.self) { feature in
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.success)

                            Text(feature)
                                .font(.labelSmall)
                                .foregroundColor(.neutral)
                        }
                    }
                }
            }
            .padding(Spacing.md)
            .background(
                isSelected ?
                Color.focusPrimary.opacity(0.1) : Color.cardBackground
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(
                        isSelected ? Color.focusPrimary : Color.clear,
                        lineWidth: 2
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Cooldown Info Card

struct CooldownInfoCard: View {
    let from: CommitmentMode
    let to: CommitmentMode

    private var isDecreasingStrictness: Bool {
        to.strictnessLevel < from.strictnessLevel
    }

    var body: some View {
        FocusCard {
            HStack(spacing: Spacing.md) {
                Image(systemName: isDecreasingStrictness ? "clock.fill" : "bolt.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isDecreasingStrictness ? .warning : .success)

                VStack(alignment: .leading, spacing: 4) {
                    Text(isDecreasingStrictness ? "24-Hour Cooldown" : "Immediate Change")
                        .font(.labelLarge)

                    Text(isDecreasingStrictness ?
                         "Decreasing protection requires a cooldown period." :
                         "Increasing protection takes effect right away."
                    )
                    .font(.labelSmall)
                    .foregroundColor(.neutral)
                }
            }
        }
    }
}

// MARK: - CommitmentMode Extensions

extension CommitmentMode {
    var features: [String] {
        switch self {
        case .gentle:
            return [
                "Usage tracking and insights",
                "No app blocking",
                "Awareness notifications",
                "Change settings anytime"
            ]
        case .standard:
            return [
                "App shields and limits",
                "Grace period access",
                "24-hour cooldown to reduce limits",
                "Partner notifications optional"
            ]
        case .locked:
            return [
                "Strongest protection",
                "Partner approval for changes",
                "Integrity alerts enabled",
                "Emergency access logged"
            ]
        }
    }
}

#Preview {
    NavigationStack {
        CommitmentModeView()
            .environmentObject(PersistenceService.shared)
    }
}
