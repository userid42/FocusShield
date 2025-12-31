import SwiftUI

// MARK: - Alternative App Button

struct AlternativeAppButton: View {
    let app: AlternativeApp
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            HapticPattern.selection()
            if let onTap = onTap {
                onTap()
            } else if let url = app.url {
                UIApplication.shared.open(url)
            }
        } label: {
            VStack(spacing: Spacing.xs) {
                Image(systemName: app.iconName)
                    .font(.system(size: 24))
                    .frame(width: 50, height: 50)
                    .background(Color.neutral.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(app.name)
                    .font(.labelSmall)
            }
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Alternative Apps Row

struct AlternativeAppsRow: View {
    let apps: [AlternativeApp]

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text("Open instead?")
                .font(.labelMedium)
                .foregroundColor(.neutral)

            HStack(spacing: Spacing.md) {
                ForEach(apps.prefix(3)) { app in
                    AlternativeAppButton(app: app)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        AlternativeAppButton(app: AlternativeApp.defaults[0])

        AlternativeAppsRow(apps: Array(AlternativeApp.defaults.prefix(3)))
    }
    .padding()
}
