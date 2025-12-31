import SwiftUI

struct OnboardingCoordinator: View {
    let onComplete: () -> Void

    @State private var currentStep: OnboardingStep = .welcome
    @State private var selectedGoal: UserGoal?
    @State private var commitmentMode: CommitmentMode = .standard
    @State private var partnerName: String = ""
    @State private var partnerContact: String = ""

    @EnvironmentObject var persistence: PersistenceService
    @EnvironmentObject var screenTimeService: ScreenTimeService

    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case goal
        case apps
        case commitment
        case accountability
        case permissions
        case complete

        var progress: Double {
            Double(rawValue) / Double(OnboardingStep.allCases.count - 1)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            if currentStep != .welcome && currentStep != .complete {
                ProgressBar(progress: currentStep.progress)
                    .frame(height: 4)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.sm)
            }

            // Content
            Group {
                switch currentStep {
                case .welcome:
                    WelcomeView(onContinue: { goToStep(.goal) })

                case .goal:
                    GoalSelectionView(
                        selectedGoal: $selectedGoal,
                        onContinue: { goToStep(.apps) },
                        onBack: { goToStep(.welcome) }
                    )

                case .apps:
                    AppSelectionView(
                        onContinue: { goToStep(.commitment) },
                        onBack: { goToStep(.goal) }
                    )

                case .commitment:
                    CommitmentLevelView(
                        selectedMode: $commitmentMode,
                        onContinue: { goToStep(.accountability) },
                        onBack: { goToStep(.apps) }
                    )

                case .accountability:
                    AccountabilitySetupView(
                        partnerName: $partnerName,
                        partnerContact: $partnerContact,
                        onContinue: { goToStep(.permissions) },
                        onSkip: { goToStep(.permissions) },
                        onBack: { goToStep(.commitment) }
                    )

                case .permissions:
                    PermissionsView(
                        onContinue: { goToStep(.complete) },
                        onBack: { goToStep(.accountability) }
                    )

                case .complete:
                    OnboardingCompleteView(onFinish: completeOnboarding)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .background(Color.backgroundStart.ignoresSafeArea())
        .animation(.smooth, value: currentStep)
    }

    private func goToStep(_ step: OnboardingStep) {
        HapticPattern.selection()
        withAnimation {
            currentStep = step
        }

        // Track analytics
        AnalyticsService.shared.trackOnboardingStep(String(describing: step))
    }

    private func completeOnboarding() {
        // Save user data
        let user = User(
            goal: selectedGoal,
            commitmentMode: commitmentMode,
            onboardingCompleted: true
        )
        persistence.saveUser(user)

        // Save partner if provided
        if !partnerName.isEmpty && !partnerContact.isEmpty {
            let contactMethod: ContactMethod = partnerContact.contains("@")
                ? .email(address: partnerContact)
                : .sms(phoneNumber: partnerContact)

            let partner = AccountabilityPartner(
                name: partnerName,
                contactMethod: contactMethod
            )
            persistence.savePartner(partner)
        }

        // Track analytics
        AnalyticsService.shared.trackOnboardingComplete(
            goal: selectedGoal,
            mode: commitmentMode
        )

        // Complete
        HapticPattern.success()
        onComplete()
    }
}

#Preview {
    OnboardingCoordinator(onComplete: {})
        .environmentObject(PersistenceService.shared)
        .environmentObject(ScreenTimeService.shared)
}
