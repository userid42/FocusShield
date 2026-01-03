import SwiftUI

struct BreathingView: View {
    let onComplete: () -> Void

    @State private var breathPhase: BreathPhase = .inhale
    @State private var circleScale: CGFloat = 0.6
    @State private var cycleCount = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var isPhaseAnnounced: Bool

    enum BreathPhase: String {
        case inhale = "Breathe in..."
        case hold = "Hold..."
        case exhale = "Breathe out..."

        var accessibilityAnnouncement: String {
            switch self {
            case .inhale: return "Breathe in for 4 seconds"
            case .hold: return "Hold for 2 seconds"
            case .exhale: return "Breathe out for 4 seconds"
            }
        }
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("Take a breath")
                .font(.displayMedium)
                .foregroundColor(.adaptiveText)
                .accessibilityAddTraits(.isHeader)

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
                            colors: [Color.focusPrimary.opacity(0.4), Color.focusSecondary.opacity(0.15)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(reduceMotion ? 0.8 : circleScale)

                // Phase text
                Text(breathPhase.rawValue)
                    .font(.headlineMedium)
                    .foregroundColor(.focusPrimary)
                    .fontWeight(.medium)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(breathPhase.accessibilityAnnouncement)
            .accessibilityFocused($isPhaseAnnounced)

            // Progress
            Text("Urges pass like waves.")
                .font(.bodyMedium)
                .foregroundColor(.neutral)
        }
        .onAppear {
            startBreathingCycle()
        }
        .onChange(of: breathPhase) { _, _ in
            // Announce phase changes for VoiceOver
            isPhaseAnnounced = true
        }
    }

    private func startBreathingCycle() {
        // Inhale (4s)
        breathPhase = .inhale
        if !reduceMotion {
            withAnimation(.easeInOut(duration: 4)) {
                circleScale = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [self] in
            // Hold (2s)
            breathPhase = .hold

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                // Exhale (4s)
                breathPhase = .exhale
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 4)) {
                        circleScale = 0.6
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    HapticPattern.success()
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    BreathingView(onComplete: {})
        .gradientBackground()
}
