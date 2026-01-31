import Foundation
import Combine

@MainActor
public class SessionDetailViewModel: ObservableObject {
    @Published public var session: Session
    @Published public var activities: [Activity] = []
    @Published public var isLoading = false
    @Published public var isSending = false
    @Published public var errorMessage: String?

    private var apiService: APIService
    private var timer: Timer?

    public init(session: Session, apiService: APIService = .shared) {
        self.session = session
        self.apiService = apiService
    }

    public func startPolling() {
        Task {
            await refreshData()
        }
        // Poll every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refreshData()
            }
        }
    }

    public func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    public func refreshData() async {
        do {
            // Update session details
            // The session.id might be the short ID or full name. API GetSession takes name or ID?
            // "The resource name of the session. Format: sessions/{session}"
            // But we stored ID as "abc123" likely. The APIService.getSession handles constructing path if needed?
            // In APIService.getSession I did: "sessions/\(id)".
            // If session.id is "abc", this works.

            async let sessionDetails = apiService.getSession(id: session.id)
            async let activitiesResponse = apiService.fetchActivities(sessionId: session.id, pageSize: 100)

            let (newSession, newActivities) = try await (sessionDetails, activitiesResponse)

            self.session = newSession
            // Sort activities by time if needed, API returns newest first usually?
            // "Lists all activities...". Default order isn't specified but usually chronological or reverse.
            // We want chronological for chat.
            let sortedActivities = (newActivities.activities ?? []).sorted { $0.createTime < $1.createTime }
            self.activities = sortedActivities

        } catch {
            print("Polling error: \(error)")
        }
    }

    public func sendMessage(text: String) async {
        guard !text.isEmpty else { return }
        isSending = true
        do {
            try await apiService.sendMessage(sessionId: session.id, prompt: text)
            await refreshData()
        } catch {
            self.errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
        isSending = false
    }

    public func approvePlan() async {
        isSending = true
        do {
            try await apiService.approvePlan(sessionId: session.id)
            await refreshData()
        } catch {
            self.errorMessage = "Failed to approve plan: \(error.localizedDescription)"
        }
        isSending = false
    }
}
