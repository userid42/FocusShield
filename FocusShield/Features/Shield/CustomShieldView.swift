import SwiftUI

struct CustomShieldView: View {
    let appName: String
    let onDone: () -> Void
    let onGrace: () -> Void
    let onRequest: () -> Void
    let onEmergency: () -> Void

    @State private var showingGraceFlow = false
    @State private var showingRequestFlow = false
    @State private var showingEmergencyFlow = false
    @State private var showingSuccess = false

    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Icon
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.focusPrimary)
                    .accessibilityHidden(true)

                // Message
                VStack(spacing: Spacing.sm) {
                    Text("You've used your \(appName) time today.")
                        .font(.headlineLarge)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)

                    Text("Choose your next move")
                        .font(.bodyMedium)
                        .foregroundColor(.neutral)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("You've used your \(appName) time today. Choose your next move")

                Spacer()

                // Options grid (2x2)
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.md) {
                        ShieldOptionButton(option: .done) {
                            HapticPattern.success()
                            showingSuccess = true
                        }

                        ShieldOptionButton(option: .grace) {
                            HapticPattern.selection()
                            showingGraceFlow = true
                        }
                    }

                    HStack(spacing: Spacing.md) {
                        ShieldOptionButton(option: .request) {
                            HapticPattern.selection()
                            showingRequestFlow = true
                        }

                        ShieldOptionButton(option: .emergency) {
                            HapticPattern.warning()
                            showingEmergencyFlow = true
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)

                // Micro-copy
                Text("A brief pause breaks autopilot.")
                    .font(.labelMedium)
                    .foregroundColor(.neutral)
                    .padding(.top, Spacing.md)

                Spacer()
            }
            .padding(Spacing.lg)
        }
        .sheet(isPresented: $showingGraceFlow) {
            GraceFlowView {
                showingGraceFlow = false
                onGrace()
            }
        }
        .sheet(isPresented: $showingRequestFlow) {
            RequestExtensionView(appName: appName) {
                showingRequestFlow = false
                onRequest()
            }
        }
        .sheet(isPresented: $showingEmergencyFlow) {
            EmergencyAccessView(appName: appName) {
                showingEmergencyFlow = false
                onEmergency()
            }
        }
        .fullScreenCover(isPresented: $showingSuccess) {
            SuccessMomentView(onDismiss: {
                showingSuccess = false
                onDone()
            })
        }
    }
}

#Preview {
    CustomShieldView(
        appName: "Instagram",
        onDone: {},
        onGrace: {},
        onRequest: {},
        onEmergency: {}
    )
}
