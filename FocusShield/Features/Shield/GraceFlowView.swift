import SwiftUI

struct GraceFlowView: View {
    let onComplete: () -> Void

    @State private var phase: GracePhase = .breathing
    @State private var selectedIntention: String?

    @Environment(\.dismiss) private var dismiss

    enum GracePhase {
        case breathing
        case intention
        case countdown
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Header with close
            HStack {
                CloseButton {
                    dismiss()
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.md)

            Spacer()

            switch phase {
            case .breathing:
                BreathingView {
                    withAnimation {
                        phase = .intention
                    }
                }

            case .intention:
                IntentionView(selectedIntention: $selectedIntention) {
                    withAnimation {
                        phase = .countdown
                    }
                }

            case .countdown:
                CountdownView(seconds: 10) {
                    onComplete()
                    dismiss()
                }
            }

            Spacer()
        }
        .background(Color.backgroundStart.ignoresSafeArea())
    }
}

#Preview {
    GraceFlowView(onComplete: {})
}
