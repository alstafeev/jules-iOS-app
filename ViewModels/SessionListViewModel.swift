import Foundation
import Combine

@MainActor
public class SessionListViewModel: ObservableObject {
    @Published public var sessions: [Session] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    private var apiService: APIService

    public init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    public func loadSessions() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await apiService.fetchSessions(pageSize: 50)
            self.sessions = response.sessions ?? []
        } catch {
            self.errorMessage = "Failed to load sessions: \(error.localizedDescription)"
        }
        isLoading = false
    }

    public func deleteSession(id: String) async {
        do {
            try await apiService.deleteSession(id: id)
            if let index = sessions.firstIndex(where: { $0.id == id || $0.name.hasSuffix(id) }) {
                sessions.remove(at: index)
            } else {
                 // Reload if we can't match ID easily (e.g. if name vs id usage is mixed)
                 await loadSessions()
            }
        } catch {
            self.errorMessage = "Failed to delete session: \(error.localizedDescription)"
        }
    }
}
