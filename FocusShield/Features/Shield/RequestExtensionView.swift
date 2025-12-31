import SwiftUI

struct RequestExtensionView: View {
    let appName: String
    let onComplete: () -> Void

    @State private var reason: String = ""
    @State private var selectedDuration: Int = 10
    @State private var isRequesting = false
    @State private var requestSent = false

    @Environment(\.dismiss) private var dismiss

    let durations = [5, 10, 15, 30]

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                if requestSent {
                    // Success state
                    VStack(spacing: Spacing.lg) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color.success.opacity(0.1))
                                .frame(width: 80, height: 80)

                            Image(systemName: "checkmark.bubble.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.success)
                        }

                        Text("Request Sent")
                            .font(.headlineLarge)

                        Text("Your accountability partner will be notified. You'll get access once they approve.")
                            .font(.bodyMedium)
                            .foregroundColor(.neutral)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)

                        Spacer()

                        PrimaryButton(title: "Done") {
                            dismiss()
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                } else {
                    // Request form
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        Text("Request more time for \(appName)")
                            .font(.headlineMedium)
                            .padding(.horizontal, Spacing.md)

                        // Duration picker
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("How long do you need?")
                                .font(.labelMedium)
                                .foregroundColor(.neutral)
                                .padding(.horizontal, Spacing.md)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Spacing.sm) {
                                    ForEach(durations, id: \.self) { duration in
                                        DurationChip(
                                            minutes: duration,
                                            isSelected: selectedDuration == duration
                                        ) {
                                            selectedDuration = duration
                                        }
                                    }
                                }
                                .padding(.horizontal, Spacing.md)
                            }
                        }

                        // Reason input
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Why do you need this? (optional)")
                                .font(.labelMedium)
                                .foregroundColor(.neutral)

                            TextField("e.g., Need to reply to a message", text: $reason)
                                .textFieldStyle(.plain)
                                .padding(Spacing.md)
                                .background(Color.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                                        .stroke(Color.neutral.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, Spacing.md)

                        // Note
                        HStack(alignment: .top, spacing: Spacing.sm) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.focusPrimary)

                            Text("Your partner will see this request and can approve or deny it.")
                                .font(.labelSmall)
                                .foregroundColor(.neutral)
                        }
                        .padding(.horizontal, Spacing.md)

                        Spacer()

                        PrimaryButton(
                            title: "Send Request",
                            action: sendRequest,
                            isLoading: isRequesting
                        )
                        .padding(.horizontal, Spacing.md)
                    }
                    .padding(.top, Spacing.md)
                }
            }
            .padding(.bottom, Spacing.lg)
            .navigationTitle("Request Extension")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sendRequest() {
        isRequesting = true

        Task {
            // Simulate sending request
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            await MainActor.run {
                isRequesting = false
                requestSent = true
                HapticPattern.success()
            }
        }
    }
}

// MARK: - Duration Chip

struct DurationChip: View {
    let minutes: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticPattern.selection()
            onTap()
        }) {
            Text("\(minutes) min")
                .font(.labelLarge)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.focusPrimary : Color.cardBackground)
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.neutral.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RequestExtensionView(appName: "Instagram", onComplete: {})
}
