import SwiftUI

public struct SessionListView: View {
    @StateObject private var viewModel = SessionListViewModel()
    @State private var showingCreateSession = false
    @State private var showingSettings = false

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if viewModel.sessions.isEmpty {
                    VStack {
                        Text("No sessions found")
                            .foregroundColor(Theme.secondaryText)
                        Button("Create your first session") {
                            showingCreateSession = true
                        }
                        .padding()
                    }
                } else {
                    List {
                        ForEach(viewModel.sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                SessionRow(session: session)
                            }
                            .listRowBackground(Theme.surface)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let session = viewModel.sessions[index]
                                Task {
                                    await viewModel.deleteSession(id: session.id)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await viewModel.loadSessions()
                    }
                }
            }
            .navigationTitle("Sessions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundColor(Theme.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateSession = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSession) {
                CreateSessionView(isPresented: $showingCreateSession) {
                    Task {
                        await viewModel.loadSessions()
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadSessions()
            }
        }
    }
}

struct SessionRow: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(session.title ?? session.prompt)
                .font(.headline)
                .foregroundColor(Theme.text)
                .lineLimit(1)

            HStack {
                StatusBadge(status: session.state)
                Text(session.createTime)
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
            }
        }
        .padding(.vertical, 5)
    }
}

struct StatusBadge: View {
    let status: SessionState

    var color: Color {
        switch status {
        case .queued, .planning: return .yellow
        case .inProgress: return .blue
        case .completed: return .green
        case .failed: return .red
        case .paused, .awaitingPlanApproval, .awaitingUserFeedback: return .orange
        default: return .gray
        }
    }

    var body: some View {
        Text(status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}
