import Foundation

// MARK: - User Model

struct User: Codable, Identifiable {
    let id: UUID
    var name: String?
    var goal: UserGoal?
    var commitmentMode: CommitmentMode
    var onboardingCompleted: Bool
    var createdAt: Date
    var lastActiveAt: Date

    init(
        id: UUID = UUID(),
        name: String? = nil,
        goal: UserGoal? = nil,
        commitmentMode: CommitmentMode = .standard,
        onboardingCompleted: Bool = false,
        createdAt: Date = Date(),
        lastActiveAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.goal = goal
        self.commitmentMode = commitmentMode
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
    }
}

// MARK: - User Goal

enum UserGoal: String, CaseIterable, Codable, Identifiable {
    case stopDoomscrolling = "Stop doomscrolling"
    case bePresent = "Be present at home"
    case focusWork = "Focus at work"
    case sleepBetter = "Sleep better"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .stopDoomscrolling: return "hand.raised.fill"
        case .bePresent: return "house.fill"
        case .focusWork: return "laptopcomputer"
        case .sleepBetter: return "moon.fill"
        }
    }

    var description: String {
        switch self {
        case .stopDoomscrolling: return "Break the endless scroll habit"
        case .bePresent: return "Put your phone down with family"
        case .focusWork: return "Eliminate distractions during work"
        case .sleepBetter: return "No screens before bed"
        }
    }

    var suggestedApps: [String] {
        switch self {
        case .stopDoomscrolling:
            return ["TikTok", "Instagram", "Twitter", "Reddit"]
        case .bePresent:
            return ["All Social Media", "Games", "YouTube"]
        case .focusWork:
            return ["Social Media", "News", "Games"]
        case .sleepBetter:
            return ["All Apps"]
        }
    }
}
