import Foundation

// MARK: - Implementation Intention

struct ImplementationIntention: Codable, Identifiable {
    let id: UUID
    var trigger: String       // "When I hit my limit at night..."
    var response: String      // "...I will plug my phone in and read 2 pages"
    var isActive: Bool
    var timesUsed: Int = 0
    var createdAt: Date

    init(
        id: UUID = UUID(),
        trigger: String,
        response: String,
        isActive: Bool = true,
        timesUsed: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.trigger = trigger
        self.response = response
        self.isActive = isActive
        self.timesUsed = timesUsed
        self.createdAt = createdAt
    }

    var fullStatement: String {
        "\(trigger) \(response)"
    }
}

// MARK: - Intention Templates

struct IntentionTemplate: Identifiable {
    let id = UUID()
    let trigger: String
    let response: String
    let category: IntentionCategory

    static let templates: [IntentionTemplate] = [
        IntentionTemplate(
            trigger: "When I hit my limit at night",
            response: "I will plug my phone in and read",
            category: .nighttime
        ),
        IntentionTemplate(
            trigger: "When I feel the urge to scroll",
            response: "I will take 3 deep breaths first",
            category: .urge
        ),
        IntentionTemplate(
            trigger: "When I open my phone out of boredom",
            response: "I will ask myself what I really need",
            category: .mindfulness
        ),
        IntentionTemplate(
            trigger: "When my time runs out",
            response: "I will go for a short walk",
            category: .activity
        ),
        IntentionTemplate(
            trigger: "When I wake up",
            response: "I will not check my phone for 30 minutes",
            category: .morning
        ),
        IntentionTemplate(
            trigger: "When I'm waiting in line",
            response: "I will observe my surroundings instead of scrolling",
            category: .mindfulness
        ),
        IntentionTemplate(
            trigger: "When I feel stressed",
            response: "I will call a friend instead of doom-scrolling",
            category: .urge
        ),
        IntentionTemplate(
            trigger: "When I'm about to open social media",
            response: "I will ask: 'What am I looking for?'",
            category: .mindfulness
        )
    ]

    static func templates(for category: IntentionCategory) -> [IntentionTemplate] {
        templates.filter { $0.category == category }
    }
}

// MARK: - Intention Category

enum IntentionCategory: String, CaseIterable, Identifiable {
    case morning = "Morning"
    case nighttime = "Nighttime"
    case urge = "Urge Management"
    case mindfulness = "Mindfulness"
    case activity = "Activity"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .nighttime: return "moon.fill"
        case .urge: return "hand.raised.fill"
        case .mindfulness: return "brain.head.profile"
        case .activity: return "figure.walk"
        }
    }
}

// MARK: - Urge Surfing

struct UrgeSurfingPhase: Identifiable {
    let id = UUID()
    let title: String
    let instruction: String
    let duration: Int  // seconds

    static let phases: [UrgeSurfingPhase] = [
        UrgeSurfingPhase(
            title: "Notice",
            instruction: "Where do you feel the urge in your body?",
            duration: 10
        ),
        UrgeSurfingPhase(
            title: "Breathe",
            instruction: "Breathe into that sensation",
            duration: 15
        ),
        UrgeSurfingPhase(
            title: "Observe",
            instruction: "Watch the urge without acting on it",
            duration: 15
        ),
        UrgeSurfingPhase(
            title: "Know",
            instruction: "This wave will pass",
            duration: 10
        )
    ]
}
