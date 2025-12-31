import SwiftUI

struct BreathingView: View {
    let onComplete: () -> Void

    @State private var breathPhase: BreathPhase = .inhale
    @State private var circleScale: CGFloat = 0.6
    @State private var cycleCount = 0

    enum BreathPhase: String {
        case inhale = "Breathe in..."
        case hold = "Hold..."
        case exhale = "Breathe out..."
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("Take a breath")
                .font(.displayMedium)

            // Breathing circle
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.focusPrimary.opacity(0.2), lineWidth: 4)
                    .frame(width: 200, height: 200)

                // Animated breathing circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.focusPrimary.opacity(0.3), Color.focusPrimary.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(circleScale)

                // Phase text
                Text(breathPhase.rawValue)
                    .font(.bodyLarge)
                    .foregroundColor(.focusPrimary)
            }

            // Progress
            Text("Urges pass like waves.")
                .font(.bodyMedium)
                .foregroundColor(.neutral)
        }
        .onAppear {
            startBreathingCycle()
        }
    }

    private func startBreathingCycle() {
        // Inhale (4s)
        breathPhase = .inhale
        withAnimation(.easeInOut(duration: 4)) {
            circleScale = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            // Hold (2s)
            breathPhase = .hold

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Exhale (4s)
                breathPhase = .exhale
                withAnimation(.easeInOut(duration: 4)) {
                    circleScale = 0.6
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    BreathingView(onComplete: {})
}
