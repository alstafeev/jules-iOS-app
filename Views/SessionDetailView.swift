import SwiftUI

public struct SessionDetailView: View {
    @StateObject private var viewModel: SessionDetailViewModel
    @State private var messageText = ""

    public init(session: Session) {
        _viewModel = StateObject(wrappedValue: SessionDetailViewModel(session: session))
    }

    public var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack {
                // Info Header
                VStack(alignment: .leading) {
                    Text(viewModel.session.title ?? viewModel.session.prompt)
                        .font(.headline)
                        .foregroundColor(Theme.text)
                    StatusBadge(status: viewModel.session.state)

                    if let outputs = viewModel.session.outputs {
                         ForEach(outputs, id: \.self) { output in
                             if let pr = output.pullRequest {
                                 Link("View PR: \(pr.title)", destination: URL(string: pr.url)!)
                                     .foregroundColor(Theme.primary)
                                     .padding(.top, 2)
                             }
                         }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Theme.surface)

                // Chat List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.activities) { activity in
                                ActivityView(activity: activity) {
                                    Task {
                                        await viewModel.approvePlan()
                                    }
                                }
                                .id(activity.id)
                            }
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: viewModel.activities) { _ in
                        if let last = viewModel.activities.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input Area
                HStack {
                    TextField("Message Jules...", text: $messageText)
                        .padding(10)
                        .background(Theme.surface)
                        .foregroundColor(Theme.text)
                        .cornerRadius(20)

                    Button(action: {
                        let text = messageText
                        messageText = ""
                        Task {
                            await viewModel.sendMessage(text: text)
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(messageText.isEmpty ? Theme.secondaryText : Theme.primary)
                    }
                    .disabled(messageText.isEmpty || viewModel.isSending)
                }
                .padding()
                .background(Theme.background)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }
}
