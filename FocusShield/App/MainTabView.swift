import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case limits = "Limits"
        case progress = "Progress"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .limits: return "clock.fill"
            case .progress: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)

            LimitsListView()
                .tabItem {
                    Label(Tab.limits.rawValue, systemImage: Tab.limits.icon)
                }
                .tag(Tab.limits)

            WeeklyReviewView()
                .tabItem {
                    Label(Tab.progress.rawValue, systemImage: Tab.progress.icon)
                }
                .tag(Tab.progress)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(.focusPrimary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(PersistenceService.shared)
        .environmentObject(ScreenTimeService.shared)
}
