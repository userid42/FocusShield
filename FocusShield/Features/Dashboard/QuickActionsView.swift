import SwiftUI

struct QuickActionsView: View {
    let onStartFocusBlock: () -> Void
    let onEditLimits: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Quick Actions")
                .font(.headlineMedium)
                .padding(.horizontal, Spacing.md)

            HStack(spacing: Spacing.md) {
                QuickActionButton(
                    icon: "shield.fill",
                    title: "Focus Block",
                    subtitle: "1 hour",
                    action: onStartFocusBlock
                )

                QuickActionButton(
                    icon: "slider.horizontal.3",
                    title: "Edit Limits",
                    action: onEditLimits
                )
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

#Preview {
    QuickActionsView(
        onStartFocusBlock: {},
        onEditLimits: {}
    )
    .background(Color.backgroundStart)
}
