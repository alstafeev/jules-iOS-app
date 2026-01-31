import Foundation
import Combine

@MainActor
public class CreateSessionViewModel: ObservableObject {
    @Published public var sources: [Source] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    // Form fields
    @Published public var selectedSource: Source?
    @Published public var selectedBranch: String = "main"
    @Published public var prompt: String = ""
    @Published public var title: String = ""
    @Published public var requirePlanApproval: Bool = false
    @Published public var automationMode: Bool = false // Toggle for AUTO_CREATE_PR

    private var apiService: APIService

    public init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    public func fetchSources() async {
        isLoading = true
        errorMessage = nil
        do {
            // Fetch all (pagination logic omitted for simplicity, fetching first page)
            let response = try await apiService.fetchSources(pageSize: 100)
            self.sources = response.sources ?? []
            if let first = self.sources.first {
                self.selectedSource = first
                self.selectedBranch = first.githubRepo?.defaultBranch?.displayName ?? "main"
            }
        } catch {
            self.errorMessage = "Failed to load sources: \(error.localizedDescription)"
        }
        isLoading = false
    }

    public func createSession() async -> Session? {
        guard let source = selectedSource, !prompt.isEmpty else {
            self.errorMessage = "Please select a source and enter a prompt."
            return nil
        }

        isLoading = true
        errorMessage = nil

        let sourceContext = SourceContext(
            source: source.name,
            githubRepoContext: GitHubRepoContext(startingBranch: selectedBranch)
        )

        let request = CreateSessionRequest(
            prompt: prompt,
            title: title.isEmpty ? nil : title,
            sourceContext: sourceContext,
            requirePlanApproval: requirePlanApproval,
            automationMode: automationMode ? "AUTO_CREATE_PR" : nil
        )

        do {
            let session = try await apiService.createSession(request: request)
            isLoading = false
            return session
        } catch {
            self.errorMessage = "Failed to create session: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
}
