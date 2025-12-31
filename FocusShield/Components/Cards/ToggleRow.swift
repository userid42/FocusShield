import SwiftUI

// MARK: - Toggle Row

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    var subtitle: String? = nil
    var isLocked: Bool = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xs) {
                    Text(title)
                        .font(.bodyMedium)
                        .foregroundColor(.primary)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.neutral)
                    }
                }

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.labelSmall)
                        .foregroundColor(.neutral)
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.focusPrimary)
                .disabled(isLocked)
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .opacity(isLocked ? 0.6 : 1.0)
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let title: String
    var icon: String? = nil
    var subtitle: String? = nil
    var value: String? = nil
    var showChevron: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticPattern.selection()
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.focusPrimary)
                        .frame(width: 28)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.bodyMedium)
                        .foregroundColor(.primary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.labelSmall)
                            .foregroundColor(.neutral)
                    }
                }

                Spacer()

                if let value = value {
                    Text(value)
                        .font(.bodyMedium)
                        .foregroundColor(.neutral)
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.neutral.opacity(0.5))
                }
            }
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        ToggleRow(
            title: "When I exceed limits",
            isOn: .constant(true),
            isLocked: true
        )

        Divider().padding(.leading, Spacing.md)

        ToggleRow(
            title: "Include app names",
            isOn: .constant(false),
            subtitle: "Share which apps triggered notifications"
        )

        Divider().padding(.leading, Spacing.md)

        SettingsRow(
            title: "Commitment Mode",
            icon: "shield.fill",
            value: "Standard"
        ) {}

        SettingsRow(
            title: "Notifications",
            icon: "bell.fill",
            subtitle: "Manage notification preferences"
        ) {}
    }
    .background(Color.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    .padding()
    .background(Color.backgroundStart)
}
