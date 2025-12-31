import SwiftUI

struct SuccessMomentView: View {
    let onDismiss: () -> Void

    @State private var showCheckmark = false
    @State private var showContent = false

    private let alternativeApps = Array(AlternativeApp.defaults.prefix(3))

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Animated checkmark
            ZStack {
                Circle()
                    .fill(Color.success.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCheckmark ? 1.0 : 0.5)
                    .opacity(showCheckmark ? 1.0 : 0)

                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(.success)
                    .scaleEffect(showCheckmark ? 1.0 : 0.3)
                    .opacity(showCheckmark ? 1.0 : 0)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCheckmark)

            if showContent {
                VStack(spacing: Spacing.sm) {
                    Text("Nice choice.")
                        .font(.displayMedium)

                    Text("You're building a new pattern.")
                        .font(.bodyMedium)
                        .foregroundColor(.neutral)
                }
                .transition(.fadeAndSlide)

                // Alternative suggestions
                AlternativeAppsRow(apps: alternativeApps)
                    .padding(.top, Spacing.lg)
                    .transition(.opacity)
            }

            Spacer()

            if showContent {
                Button("Go to Home") {
                    onDismiss()
                }
                .font(.labelLarge)
                .foregroundColor(.neutral)
                .transition(.opacity)

                Spacer()
                    .frame(height: Spacing.lg)
            }
        }
        .padding(Spacing.lg)
        .background(Color.backgroundStart.ignoresSafeArea())
        .onAppear {
            HapticPattern.success()

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

#Preview {
    SuccessMomentView(onDismiss: {})
}
