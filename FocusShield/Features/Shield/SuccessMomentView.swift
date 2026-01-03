import SwiftUI

struct SuccessMomentView: View {
    let onDismiss: () -> Void

    @State private var showCheckmark = false
    @State private var showContent = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let alternativeApps = Array(AlternativeApp.defaults.prefix(3))

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Animated checkmark
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.focusPrimary.opacity(0.15), Color.focusSecondary.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCheckmark ? 1.0 : (reduceMotion ? 1.0 : 0.5))
                    .opacity(showCheckmark ? 1.0 : 0)

                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.focusPrimary, Color.focusSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(showCheckmark ? 1.0 : (reduceMotion ? 1.0 : 0.3))
                    .opacity(showCheckmark ? 1.0 : 0)
            }
            .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.6), value: showCheckmark)
            .accessibilityLabel("Success")

            if showContent {
                VStack(spacing: Spacing.sm) {
                    Text("Nice choice.")
                        .font(.displayMedium)
                        .foregroundColor(.adaptiveText)
                        .accessibilityAddTraits(.isHeader)

                    Text("You're building a new pattern.")
                        .font(.bodyMedium)
                        .foregroundColor(.neutral)
                }
                .transition(reduceMotion ? .opacity : .fadeAndSlide)

                // Alternative suggestions
                AlternativeAppsRow(apps: alternativeApps)
                    .padding(.top, Spacing.lg)
                    .transition(.opacity)
                    .accessibilityLabel("Alternative activities")
            }

            Spacer()

            if showContent {
                Button("Go to Home") {
                    HapticPattern.selection()
                    onDismiss()
                }
                .font(.labelLarge)
                .foregroundColor(.focusPrimary)
                .padding(.vertical, Spacing.sm)
                .transition(.opacity)
                .accessibilityHint("Closes this screen")

                Spacer()
                    .frame(height: Spacing.lg)
            }
        }
        .padding(Spacing.lg)
        .background(LinearGradient.backgroundGradient.ignoresSafeArea())
        .onAppear {
            HapticPattern.success()

            if reduceMotion {
                showCheckmark = true
                showContent = true
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showCheckmark = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showContent = true
                    }
                }
            }
        }
    }
}

#Preview {
    SuccessMomentView(onDismiss: {})
}
