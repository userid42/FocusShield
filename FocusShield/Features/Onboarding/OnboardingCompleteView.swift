import SwiftUI

struct OnboardingCompleteView: View {
    let onFinish: () -> Void

    @State private var showContent = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Success animation
            ZStack {
                // Background circles
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.focusPrimary.opacity(0.15 - Double(i) * 0.04), lineWidth: 2)
                        .frame(width: CGFloat(120 + i * 40), height: CGFloat(120 + i * 40))
                        .scaleEffect(showContent ? 1 : (reduceMotion ? 1 : 0.5))
                        .opacity(showContent ? 1 : 0)
                        .animation(
                            reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.7).delay(Double(i) * 0.1),
                            value: showContent
                        )
                }

                // Checkmark
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.focusPrimary, Color.focusSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.focusPrimary.opacity(0.3), radius: 12, y: 4)

                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showContent ? 1 : (reduceMotion ? 1 : 0))
                .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: showContent)
            }
            .accessibilityHidden(true)

            // Text
            VStack(spacing: Spacing.sm) {
                Text("You're ready!")
                    .font(.displayLarge)
                    .foregroundColor(.adaptiveText)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : (reduceMotion ? 0 : 20))
                    .animation(reduceMotion ? .none : .spring(response: 0.6).delay(0.5), value: showContent)
                    .accessibilityAddTraits(.isHeader)

                Text("FocusShield is set up and protecting your time.")
                    .font(.bodyLarge)
                    .foregroundColor(.neutral)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : (reduceMotion ? 0 : 20))
                    .animation(reduceMotion ? .none : .spring(response: 0.6).delay(0.6), value: showContent)
            }
            .padding(.horizontal, Spacing.lg)

            Spacer()

            // Tips
            VStack(alignment: .leading, spacing: Spacing.md) {
                TipRow(
                    icon: "lightbulb.fill",
                    text: "Open a blocked app to see your options"
                )

                TipRow(
                    icon: "chart.bar.fill",
                    text: "Check your progress in the Progress tab"
                )

                TipRow(
                    icon: "gearshape.fill",
                    text: "Adjust limits anytime in Settings"
                )
            }
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadow(color: Color.focusPrimary.opacity(0.06), radius: 8, y: 2)
            .padding(.horizontal, Spacing.md)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : (reduceMotion ? 0 : 30))
            .animation(reduceMotion ? .none : .spring(response: 0.6).delay(0.7), value: showContent)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Quick tips")

            Spacer()

            // Finish button
            PrimaryButton(
                title: "Start Using FocusShield",
                action: onFinish,
                icon: "checkmark.circle.fill",
                accessibilityHint: "Completes setup and opens the app"
            )
            .padding(.horizontal, Spacing.md)
            .opacity(showContent ? 1 : 0)
            .animation(reduceMotion ? .none : .spring(response: 0.6).delay(0.9), value: showContent)

            Spacer()
                .frame(height: Spacing.lg)
        }
        .onAppear {
            showContent = true
            HapticPattern.success()
        }
    }
}

// MARK: - Tip Row

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.focusPrimary)
                .frame(width: 24)

            Text(text)
                .font(.bodyMedium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    OnboardingCompleteView(onFinish: {})
}
