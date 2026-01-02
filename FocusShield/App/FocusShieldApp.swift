import SwiftUI
import FamilyControls

@main
struct FocusShieldApp: App {
    @StateObject private var persistence = PersistenceService.shared
    @StateObject private var screenTimeService = ScreenTimeService.shared
    @StateObject private var integrityMonitor = IntegrityMonitorService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(persistence)
                .environmentObject(screenTimeService)
                .environmentObject(integrityMonitor)
                .preferredColorScheme(persistence.appSettings.appearanceMode.colorScheme)
                .tint(.focusPrimary)
        }
    }
}
