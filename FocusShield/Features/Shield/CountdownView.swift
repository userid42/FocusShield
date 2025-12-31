import SwiftUI

struct CountdownView: View {
    let seconds: Int
    let onComplete: () -> Void

    @State private var remainingSeconds: Int
    @State private var timer: Timer?

    init(seconds: Int, onComplete: @escaping () -> Void) {
        self.seconds = seconds
        self.onComplete = onComplete
        self._remainingSeconds = State(initialValue: seconds)
    }

    private var progress: Double {
        1.0 - (Double(remainingSeconds) / Double(seconds))
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("Grace period starting...")
                .font(.headlineMedium)
                .foregroundColor(.neutral)

            // Countdown ring
            ZStack {
                Circle()
                    .stroke(Color.neutral.opacity(0.2), lineWidth: 8)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.focusPrimary,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                Text("\(remainingSeconds)")
                    .font(.timer)
                    .fontWeight(.medium)
            }

            Text("You'll have 2 minutes")
                .font(.bodyMedium)
                .foregroundColor(.neutral)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                if remainingSeconds <= 3 {
                    HapticPattern.lightImpact()
                }
            } else {
                timer?.invalidate()
                HapticPattern.success()
                onComplete()
            }
        }
    }
}

#Preview {
    CountdownView(seconds: 10, onComplete: {})
}
