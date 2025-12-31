import Foundation

// MARK: - Alternative App

struct AlternativeApp: Identifiable, Codable {
    let id: UUID
    let name: String
    let iconName: String
    let urlScheme: String
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        urlScheme: String,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.urlScheme = urlScheme
        self.isEnabled = isEnabled
    }

    var url: URL? {
        URL(string: urlScheme)
    }
}

// MARK: - Default Alternatives

extension AlternativeApp {
    static let defaults: [AlternativeApp] = [
        AlternativeApp(
            name: "Kindle",
            iconName: "book.fill",
            urlScheme: "kindle://"
        ),
        AlternativeApp(
            name: "Notes",
            iconName: "note.text",
            urlScheme: "mobilenotes://"
        ),
        AlternativeApp(
            name: "Podcasts",
            iconName: "mic.fill",
            urlScheme: "podcasts://"
        ),
        AlternativeApp(
            name: "Music",
            iconName: "music.note",
            urlScheme: "music://"
        ),
        AlternativeApp(
            name: "Books",
            iconName: "books.vertical.fill",
            urlScheme: "ibooks://"
        ),
        AlternativeApp(
            name: "Reminders",
            iconName: "checklist",
            urlScheme: "x-apple-reminderkit://"
        ),
        AlternativeApp(
            name: "Messages",
            iconName: "message.fill",
            urlScheme: "messages://"
        ),
        AlternativeApp(
            name: "Phone",
            iconName: "phone.fill",
            urlScheme: "tel://"
        )
    ]

    static func forGoal(_ goal: UserGoal?) -> [AlternativeApp] {
        guard let goal = goal else { return Array(defaults.prefix(3)) }

        switch goal {
        case .stopDoomscrolling:
            return [
                defaults.first { $0.name == "Kindle" }!,
                defaults.first { $0.name == "Notes" }!,
                defaults.first { $0.name == "Podcasts" }!
            ]
        case .bePresent:
            return [
                defaults.first { $0.name == "Messages" }!,
                defaults.first { $0.name == "Phone" }!,
                defaults.first { $0.name == "Reminders" }!
            ]
        case .focusWork:
            return [
                defaults.first { $0.name == "Notes" }!,
                defaults.first { $0.name == "Reminders" }!,
                defaults.first { $0.name == "Music" }!
            ]
        case .sleepBetter:
            return [
                defaults.first { $0.name == "Books" }!,
                defaults.first { $0.name == "Podcasts" }!,
                defaults.first { $0.name == "Music" }!
            ]
        }
    }
}

// MARK: - Substitution Config

struct SubstitutionConfig: Codable {
    var alternativeApps: [AlternativeApp]
    var showOnShield: Bool = true
    var maxToShow: Int = 3

    init(
        alternativeApps: [AlternativeApp] = AlternativeApp.defaults,
        showOnShield: Bool = true,
        maxToShow: Int = 3
    ) {
        self.alternativeApps = alternativeApps
        self.showOnShield = showOnShield
        self.maxToShow = maxToShow
    }

    var enabledApps: [AlternativeApp] {
        alternativeApps.filter { $0.isEnabled }
    }

    var appsToShow: [AlternativeApp] {
        Array(enabledApps.prefix(maxToShow))
    }
}
