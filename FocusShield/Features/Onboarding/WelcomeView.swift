import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Logo/Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.focusPrimary.opacity(0.2), Color.focusSecondary.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                Image(systemName: "shield.checkered")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.focusPrimary, Color.focusSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)

            // Title
            VStack(spacing: Spacing.sm) {
                Text("FocusShield")
                    .font(.displayLarge)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showContent)

                Text("Build better phone habits with\naccountability that works")
                    .font(.bodyLarge)
                    .foregroundColor(.neutral)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showContent)
            }

            Spacer()

            // Value props
            VStack(alignment: .leading, spacing: Spacing.md) {
                ValuePropRow(
                    icon: "clock.fill",
                    title: "Set meaningful limits",
                    subtitle: "Daily budgets for your distracting apps"
                )

                ValuePropRow(
                    icon: "hand.raised.fill",
                    title: "Friction when you need it",
                    subtitle: "Pause and breathe before diving in"
                )

                ValuePropRow(
                    icon: "person.2.fill",
                    title: "Real accountability",
                    subtitle: "Someone you trust knows when you slip"
                )
            }
            .padding(.horizontal, Spacing.md)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: showContent)

            Spacer()

            // Continue button
            PrimaryButton(title: "Get Started", action: onContinue)
                .padding(.horizontal, Spacing.md)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showContent)

            // Privacy note
            Text("2 minutes to set up. No account required.")
                .font(.labelSmall)
                .foregroundColor(.neutral)
                .padding(.bottom, Spacing.lg)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.9), value: showContent)
        }
        .onAppear {
            showContent = true
        }
    }
}

// MARK: - Value Prop Row

struct ValuePropRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.focusPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.labelLarge)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.bodySmall)
                    .foregroundColor(.neutral)
            }
        }
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
