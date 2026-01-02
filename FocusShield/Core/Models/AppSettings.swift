import SwiftUI

// MARK: - App Settings

/// Central settings model for app-wide preferences
struct AppSettings: Codable, Equatable {
    var appearanceMode: AppearanceMode = .automatic
    var proFeaturesEnabled: Bool = false
    var hapticsEnabled: Bool = true
    var reducedMotion: Bool = false

    init(
        appearanceMode: AppearanceMode = .automatic,
        proFeaturesEnabled: Bool = false,
        hapticsEnabled: Bool = true,
        reducedMotion: Bool = false
    ) {
        self.appearanceMode = appearanceMode
        self.proFeaturesEnabled = proFeaturesEnabled
        self.hapticsEnabled = hapticsEnabled
        self.reducedMotion = reducedMotion
    }
}

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable, Codable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case automatic = "Automatic"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .automatic: return "circle.lefthalf.filled"
        }
    }

    var description: String {
        switch self {
        case .light: return "Always use light appearance"
        case .dark: return "Always use dark appearance"
        case .automatic: return "Match system setting"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .automatic: return nil
        }
    }
}

// MARK: - Pro Features

/// Defines which features require Pro subscription
enum ProFeature: String, CaseIterable, Identifiable {
    case unlimitedLimits = "unlimited_limits"
    case advancedAnalytics = "advanced_analytics"
    case customTimeWindows = "custom_time_windows"
    case multiplePartners = "multiple_partners"
    case exportData = "export_data"
    case customIntentions = "custom_intentions"
    case prioritySupport = "priority_support"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .unlimitedLimits: return "Unlimited Limits"
        case .advancedAnalytics: return "Advanced Analytics"
        case .customTimeWindows: return "Custom Time Windows"
        case .multiplePartners: return "Multiple Partners"
        case .exportData: return "Data Export"
        case .customIntentions: return "Custom Intentions"
        case .prioritySupport: return "Priority Support"
        }
    }

    var description: String {
        switch self {
        case .unlimitedLimits: return "Create as many app limits as you need"
        case .advancedAnalytics: return "Deeper insights into your usage patterns"
        case .customTimeWindows: return "Schedule custom blocking windows"
        case .multiplePartners: return "Add multiple accountability partners"
        case .exportData: return "Export your data in various formats"
        case .customIntentions: return "Create your own implementation intentions"
        case .prioritySupport: return "Get faster help when you need it"
        }
    }

    var icon: String {
        switch self {
        case .unlimitedLimits: return "infinity"
        case .advancedAnalytics: return "chart.xyaxis.line"
        case .customTimeWindows: return "calendar.badge.clock"
        case .multiplePartners: return "person.3.fill"
        case .exportData: return "square.and.arrow.up"
        case .customIntentions: return "brain.head.profile"
        case .prioritySupport: return "star.fill"
        }
    }
}

// MARK: - Free Tier Limits

enum FreeTierLimits {
    static let maxLimits: Int = 3
    static let maxTimeWindows: Int = 1
    static let maxIntentions: Int = 3
    static let maxPartners: Int = 1
}
