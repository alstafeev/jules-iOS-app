import SwiftUI

public struct CreateSessionView: View {
    @Binding var isPresented: Bool
    var onSessionCreated: () -> Void

    @StateObject private var viewModel = CreateSessionViewModel()

    public var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(Theme.error)
                                .font(.caption)
                        }

                        // Source Selection
                        VStack(alignment: .leading) {
                            Text("Repository")
                                .foregroundColor(Theme.secondaryText)
                                .font(.caption)

                            if viewModel.isLoading && viewModel.sources.isEmpty {
                                ProgressView()
                            } else {
                                Picker("Repository", selection: $viewModel.selectedSource) {
                                    ForEach(viewModel.sources) { source in
                                        Text(source.githubRepo?.repo ?? source.name).tag(source as Source?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .background(Theme.surface)
                                .cornerRadius(8)
                            }
                        }

                        if let source = viewModel.selectedSource, let branches = source.githubRepo?.branches {
                            VStack(alignment: .leading) {
                                Text("Branch")
                                    .foregroundColor(Theme.secondaryText)
                                    .font(.caption)

                                Picker("Branch", selection: $viewModel.selectedBranch) {
                                    ForEach(branches, id: \.self) { branch in
                                        Text(branch.displayName).tag(branch.displayName)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .background(Theme.surface)
                                .cornerRadius(8)
                            }
                        }

                        JulesTextField(title: "Title (Optional)", text: $viewModel.title)

                        VStack(alignment: .leading) {
                            Text("Prompt")
                                .foregroundColor(Theme.secondaryText)
                                .font(.caption)

                            TextEditor(text: $viewModel.prompt)
                                .frame(height: 100)
                                .padding(5)
                                .background(Theme.surface)
                                .cornerRadius(8)
                                .foregroundColor(Theme.text)
                        }

                        Toggle("Require Plan Approval", isOn: $viewModel.requirePlanApproval)
                            .foregroundColor(Theme.text)

                        Toggle("Auto Create PR", isOn: $viewModel.automationMode)
                            .foregroundColor(Theme.text)

                        Spacer(minLength: 20)

                        PrimaryButton(title: "Start Session", action: {
                            Task {
                                if await viewModel.createSession() != nil {
                                    onSessionCreated()
                                    isPresented = false
                                }
                            }
                        }, isLoading: viewModel.isLoading)

                    }
                    .padding()
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchSources()
                }
            }
        }
    }
}
