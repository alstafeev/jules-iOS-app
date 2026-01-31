import Foundation

public enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case missingAPIKey
}

public class APIService: ObservableObject {
    public static let shared = APIService()

    private let baseURL = URL(string: "https://jules.googleapis.com/v1alpha")!

    @Published public var apiKey: String = ""

    public init() {}

    private func makeRequest(endpoint: String, method: String = "GET", body: Data? = nil, queryItems: [URLQueryItem]? = nil) async throws -> Data {
        guard !apiKey.isEmpty else {
            throw APIError.missingAPIKey
        }

        var url = baseURL.appendingPathComponent(endpoint)

        if let queryItems = queryItems {
            url.append(queryItems: queryItems)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            // Try to read error body
            if let errorString = String(data: data, encoding: .utf8) {
                print("Server error: \(errorString)")
            }
            throw APIError.serverError(-1)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
             if let errorString = String(data: data, encoding: .utf8) {
                print("Server error status \(httpResponse.statusCode): \(errorString)")
            }
            throw APIError.serverError(httpResponse.statusCode)
        }

        return data
    }

    // Helper to decode
    public func request<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil, queryItems: [URLQueryItem]? = nil) async throws -> T {
        let data = try await makeRequest(endpoint: endpoint, method: method, body: body, queryItems: queryItems)
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    // Helper for requests with no response body
    public func requestVoid(endpoint: String, method: String = "GET", body: Data? = nil, queryItems: [URLQueryItem]? = nil) async throws {
        _ = try await makeRequest(endpoint: endpoint, method: method, body: body, queryItems: queryItems)
    }
}

// MARK: - Sessions
extension APIService {
    public func fetchSessions(pageSize: Int = 30, pageToken: String? = nil) async throws -> ListSessionsResponse {
        var queryItems = [URLQueryItem(name: "pageSize", value: String(pageSize))]
        if let pageToken = pageToken {
            queryItems.append(URLQueryItem(name: "pageToken", value: pageToken))
        }
        return try await request(endpoint: "sessions", queryItems: queryItems)
    }

    public func createSession(request: CreateSessionRequest) async throws -> Session {
        let body = try JSONEncoder().encode(request)
        return try await self.request(endpoint: "sessions", method: "POST", body: body)
    }

    public func getSession(id: String) async throws -> Session {
        return try await self.request(endpoint: "sessions/\(id)")
    }

    public func deleteSession(id: String) async throws {
        try await requestVoid(endpoint: "sessions/\(id)", method: "DELETE")
    }
}

// MARK: - Activities
extension APIService {
    public func fetchActivities(sessionId: String, pageSize: Int = 30, pageToken: String? = nil) async throws -> ListActivitiesResponse {
        var queryItems = [URLQueryItem(name: "pageSize", value: String(pageSize))]
        if let pageToken = pageToken {
            queryItems.append(URLQueryItem(name: "pageToken", value: pageToken))
        }
        // sessionId should be the ID part, so path is sessions/{sessionId}/activities
        // If sessionId is full name, I need to be careful. I'll assume ID.
        return try await request(endpoint: "sessions/\(sessionId)/activities", queryItems: queryItems)
    }

    public func sendMessage(sessionId: String, prompt: String) async throws {
        let requestBody = SendMessageRequest(prompt: prompt)
        let body = try JSONEncoder().encode(requestBody)
        try await requestVoid(endpoint: "sessions/\(sessionId):sendMessage", method: "POST", body: body)
    }

    public func approvePlan(sessionId: String) async throws {
        let requestBody = ApprovePlanRequest()
        let body = try JSONEncoder().encode(requestBody)
        try await requestVoid(endpoint: "sessions/\(sessionId):approvePlan", method: "POST", body: body)
    }
}

// MARK: - Sources
extension APIService {
    public func fetchSources(pageSize: Int = 30, pageToken: String? = nil, filter: String? = nil) async throws -> ListSourcesResponse {
        var queryItems = [URLQueryItem(name: "pageSize", value: String(pageSize))]
        if let pageToken = pageToken {
            queryItems.append(URLQueryItem(name: "pageToken", value: pageToken))
        }
        if let filter = filter {
            queryItems.append(URLQueryItem(name: "filter", value: filter))
        }
        return try await request(endpoint: "sources", queryItems: queryItems)
    }

    public func getSource(id: String) async throws -> Source {
        return try await request(endpoint: "sources/\(id)")
    }
}
