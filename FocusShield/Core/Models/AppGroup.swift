import Foundation

// MARK: - App Group Template

enum AppGroupTemplate: String, CaseIterable, Identifiable {
    case shortForm = "Short-form"       // TikTok, Reels, Shorts
    case social = "Social"               // Instagram, Facebook, X, Threads
    case news = "News Spiral"            // News apps, Reddit
    case games = "Games"                 // All games category
    case entertainment = "Entertainment" // YouTube, Netflix, streaming

    var id: String { rawValue }

    var description: String {
        switch self {
        case .shortForm: return "TikTok, Instagram Reels, YouTube Shorts"
        case .social: return "Instagram, Facebook, X, Threads, Snapchat"
        case .news: return "News apps, Reddit, Apple News"
        case .games: return "All mobile games"
        case .entertainment: return "YouTube, Netflix, streaming apps"
        }
    }

    var suggestedLimit: Int {
        switch self {
        case .shortForm: return 15
        case .social: return 30
        case .news: return 20
        case .games: return 30
        case .entertainment: return 60
        }
    }

    var iconName: String {
        switch self {
        case .shortForm: return "play.rectangle.fill"
        case .social: return "bubble.left.and.bubble.right.fill"
        case .news: return "newspaper.fill"
        case .games: return "gamecontroller.fill"
        case .entertainment: return "tv.fill"
        }
    }

    var color: String {
        switch self {
        case .shortForm: return "danger"
        case .social: return "focusPrimary"
        case .news: return "warning"
        case .games: return "focusSecondary"
        case .entertainment: return "success"
        }
    }

    // Bundle identifiers commonly associated with each category
    var commonBundleIds: [String] {
        switch self {
        case .shortForm:
            return [
                "com.zhiliaoapp.musically", // TikTok
                "com.burbn.instagram",       // Instagram (for Reels)
                "com.google.ios.youtube"     // YouTube (for Shorts)
            ]
        case .social:
            return [
                "com.burbn.instagram",
                "com.facebook.Facebook",
                "com.atebits.Tweetie2",      // Twitter/X
                "com.toyopagroup.picaboo",   // Snapchat
                "barcelona"                   // Threads
            ]
        case .news:
            return [
                "com.reddit.Reddit",
                "com.apple.news",
                "com.google.GoogleMobile"
            ]
        case .games:
            return [] // Use category token for all games
        case .entertainment:
            return [
                "com.google.ios.youtube",
                "com.netflix.Netflix",
                "com.hulu.plus",
                "com.disney.disneyplus"
            ]
        }
    }
}

// MARK: - Custom App Group

struct CustomAppGroup: Codable, Identifiable {
    let id: UUID
    var name: String
    var appTokensData: Data?
    var categoryTokensData: Data?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        appTokensData: Data? = nil,
        categoryTokensData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.appTokensData = appTokensData
        self.categoryTokensData = categoryTokensData
        self.createdAt = createdAt
    }
}
