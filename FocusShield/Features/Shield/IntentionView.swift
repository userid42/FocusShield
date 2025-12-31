import SwiftUI

struct IntentionView: View {
    @Binding var selectedIntention: String?
    let onContinue: () -> Void

    let intentions = [
        "Check a specific thing",
        "Reply to someone",
        "Just want to scroll"
    ]

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("What do you need right now?")
                .font(.headlineLarge)
                .multilineTextAlignment(.center)

            VStack(spacing: Spacing.sm) {
                ForEach(intentions, id: \.self) { intention in
                    Button {
                        HapticPattern.selection()
                        selectedIntention = intention
                    } label: {
                        HStack {
                            Text(intention)
                                .font(.bodyLarge)
                            Spacer()
                            if selectedIntention == intention {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.focusPrimary)
                            }
                        }
                        .padding(Spacing.md)
                        .background(
                            selectedIntention == intention ?
                            Color.focusPrimary.opacity(0.1) : Color.cardBackground
                        )
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.md)

            if selectedIntention != nil {
                PrimaryButton(title: "Continue", action: onContinue)
                    .padding(.horizontal, Spacing.md)
                    .transition(.fadeAndSlide)
            }

            // Awareness prompt for "just scrolling"
            if selectedIntention == "Just want to scroll" {
                Text("That's honest. You can still proceed, but consider: what else could you do with this time?")
                    .font(.bodySmall)
                    .foregroundColor(.neutral)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
                    .transition(.fadeAndSlide)
            }
        }
        .animation(.smooth, value: selectedIntention)
    }
}

#Preview {
    IntentionView(
        selectedIntention: .constant(nil),
        onContinue: {}
    )
}
