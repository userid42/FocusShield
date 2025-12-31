import SwiftUI

struct UrgeSurfingView: View {
    let onComplete: () -> Void

    @State private var currentPhaseIndex = 0
    @State private var phaseProgress: Double = 0
    @State private var timer: Timer?

    private let phases = UrgeSurfingPhase.phases

    private var currentPhase: UrgeSurfingPhase {
        phases[currentPhaseIndex]
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Phase indicator
            HStack(spacing: Spacing.sm) {
                ForEach(0..<phases.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPhaseIndex ? Color.focusPrimary : Color.neutral.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            // Phase content
            VStack(spacing: Spacing.md) {
                Text(currentPhase.title)
                    .font(.displayMedium)
                    .foregroundColor(.focusPrimary)

                Text(currentPhase.instruction)
                    .font(.bodyLarge)
                    .foregroundColor(.neutral)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.neutral.opacity(0.2), lineWidth: 6)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: phaseProgress)
                    .stroke(
                        Color.focusPrimary,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
            }

            Text("Urges typically peak and subside\nwithin 15-30 minutes")
                .font(.labelMedium)
                .foregroundColor(.neutral)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .onAppear {
            startPhase()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startPhase() {
        phaseProgress = 0
        let duration = Double(currentPhase.duration)

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            phaseProgress += 0.1 / duration

            if phaseProgress >= 1.0 {
                timer?.invalidate()
                moveToNextPhase()
            }
        }
    }

    private func moveToNextPhase() {
        if currentPhaseIndex < phases.count - 1 {
            currentPhaseIndex += 1
            startPhase()
        } else {
            HapticPattern.success()
            onComplete()
        }
    }
}

#Preview {
    UrgeSurfingView(onComplete: {})
}
