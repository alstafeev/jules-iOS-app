import Foundation

// MARK: - Session

public struct Session: Codable, Identifiable, Hashable {
    public let name: String
    public let id: String
    public let prompt: String
    public let title: String?
    public let state: SessionState
    public let url: String?
    public let createTime: String
    public let updateTime: String
    public let sourceContext: SourceContext?
    public let outputs: [SessionOutput]?

    // Helper for date parsing if needed, but keeping as String for now to match API exact response
}

public enum SessionState: String, Codable, CaseIterable {
    case queued = "QUEUED"
    case planning = "PLANNING"
    case awaitingPlanApproval = "AWAITING_PLAN_APPROVAL"
    case awaitingUserFeedback = "AWAITING_USER_FEEDBACK"
    case inProgress = "IN_PROGRESS"
    case paused = "PAUSED"
    case completed = "COMPLETED"
    case failed = "FAILED"
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = SessionState(rawValue: rawValue) ?? .unknown
    }
}

public struct SessionOutput: Codable, Hashable {
    public let pullRequest: PullRequest?
}

public struct PullRequest: Codable, Hashable {
    public let url: String
    public let title: String
    public let description: String
}

public struct CreateSessionRequest: Codable {
    public let prompt: String
    public let title: String?
    public let sourceContext: SourceContext
    public let requirePlanApproval: Bool?
    public let automationMode: String?

    public init(prompt: String, title: String?, sourceContext: SourceContext, requirePlanApproval: Bool? = nil, automationMode: String? = nil) {
        self.prompt = prompt
        self.title = title
        self.sourceContext = sourceContext
        self.requirePlanApproval = requirePlanApproval
        self.automationMode = automationMode
    }
}

public struct ListSessionsResponse: Codable {
    public let sessions: [Session]?
    public let nextPageToken: String?
}

// MARK: - Source

public struct Source: Codable, Identifiable, Hashable {
    public let name: String
    public let id: String
    public let githubRepo: GitHubRepo?
}

public struct GitHubRepo: Codable, Hashable {
    public let owner: String
    public let repo: String
    public let isPrivate: Bool?
    public let defaultBranch: Branch?
    public let branches: [Branch]?
}

public struct Branch: Codable, Hashable {
    public let displayName: String
}

public struct SourceContext: Codable, Hashable {
    public let source: String
    public let githubRepoContext: GitHubRepoContext?

    public init(source: String, githubRepoContext: GitHubRepoContext?) {
        self.source = source
        self.githubRepoContext = githubRepoContext
    }
}

public struct GitHubRepoContext: Codable, Hashable {
    public let startingBranch: String

    public init(startingBranch: String) {
        self.startingBranch = startingBranch
    }
}

public struct ListSourcesResponse: Codable {
    public let sources: [Source]?
    public let nextPageToken: String?
}

// MARK: - Activity

public struct Activity: Codable, Identifiable, Hashable {
    public let name: String
    public let id: String
    public let originator: String // "system", "agent", "user"
    public let description: String?
    public let createTime: String

    // One of these will be populated
    public let planGenerated: PlanGenerated?
    public let planApproved: PlanApproved?
    public let userMessaged: UserMessaged?
    public let agentMessaged: AgentMessaged?
    public let progressUpdated: ProgressUpdated?
    public let sessionCompleted: SessionCompleted?
    public let sessionFailed: SessionFailed?

    public let artifacts: [ArtifactWrapper]?
}

public struct ListActivitiesResponse: Codable {
    public let activities: [Activity]?
    public let nextPageToken: String?
}

// MARK: - Activity Types

public struct PlanGenerated: Codable, Hashable {
    public let plan: Plan
}

public struct Plan: Codable, Hashable {
    public let id: String
    public let steps: [PlanStep]
    public let createTime: String?
}

public struct PlanStep: Codable, Identifiable, Hashable {
    public let id: String
    public let index: Int
    public let title: String
    public let description: String
}

public struct PlanApproved: Codable, Hashable {
    public let planId: String
}

public struct UserMessaged: Codable, Hashable {
    public let userMessage: String
}

public struct AgentMessaged: Codable, Hashable {
    public let agentMessage: String
}

public struct ProgressUpdated: Codable, Hashable {
    public let title: String
    public let description: String?
}

public struct SessionCompleted: Codable, Hashable {}

public struct SessionFailed: Codable, Hashable {
    public let reason: String
}

// MARK: - Artifacts

public struct ArtifactWrapper: Codable, Hashable {
    public let changeSet: ChangeSet?
    public let bashOutput: BashOutput?
    public let media: Media?
}

public struct ChangeSet: Codable, Hashable {
    public let source: String
    public let gitPatch: GitPatch?
}

public struct GitPatch: Codable, Hashable {
    public let baseCommitId: String?
    public let unidiffPatch: String?
    public let suggestedCommitMessage: String?
}

public struct BashOutput: Codable, Hashable {
    public let command: String
    public let output: String
    public let exitCode: Int
}

public struct Media: Codable, Hashable {
    public let mimeType: String
    public let data: String // Base64 encoded
}

// MARK: - Requests

public struct SendMessageRequest: Codable {
    public let prompt: String

    public init(prompt: String) {
        self.prompt = prompt
    }
}

public struct ApprovePlanRequest: Codable {
    // Empty body
    public init() {}
}
