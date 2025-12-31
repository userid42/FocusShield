import SwiftUI

struct OnboardingCompleteView: View {
    let onFinish: () -> Void

    @State private var showContent = false
    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Success animation
            ZStack {
                // Background circles
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.success.opacity(0.2 - Double(i) * 0.05), lineWidth: 2)
                        .frame(width: CGFloat(120 + i * 40), height: CGFloat(120 + i * 40))
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                                .delay(Double(i) * 0.1),
                            value: showContent
                        )
                }

                // Checkmark
                ZStack {
                    Circle()
                        .fill(Color.success)
                        .frame(width: 80, height: 80)

                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showContent ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: showContent)
            }

            // Text
            VStack(spacing: Spacing.sm) {
                Text("You're ready!")
                    .font(.displayLarge)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6).delay(0.5), value: showContent)

                Text("FocusShield is set up and protecting your time.")
                    .font(.bodyLarge)
                    .foregroundColor(.neutral)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6).delay(0.6), value: showContent)
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
            .padding(.horizontal, Spacing.md)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)
            .animation(.spring(response: 0.6).delay(0.7), value: showContent)

            Spacer()

            // Finish button
            PrimaryButton(title: "Start Using FocusShield", action: onFinish)
                .padding(.horizontal, Spacing.md)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.6).delay(0.9), value: showContent)

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
