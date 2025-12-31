import SwiftUI

struct ContentView: View {
    @EnvironmentObject var persistence: PersistenceService
    @State private var showOnboarding: Bool = false

    var body: some View {
        Group {
            if showOnboarding || !persistence.isOnboardingCompleted {
                OnboardingCoordinator(onComplete: {
                    withAnimation {
                        showOnboarding = false
                        persistence.isOnboardingCompleted = true
                    }
                })
            } else {
                MainTabView()
            }
        }
        .onAppear {
            showOnboarding = !persistence.isOnboardingCompleted
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PersistenceService.shared)
        .environmentObject(ScreenTimeService.shared)
        .environmentObject(IntegrityMonitorService.shared)
}
