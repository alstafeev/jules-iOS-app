import SwiftUI

struct ActivityView: View {
    let activity: Activity
    var onApprovePlan: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            if isUser {
                Spacer()
            }

            VStack(alignment: isUser ? .trailing : .leading) {
                // Header
                Text(activity.originator.capitalized)
                    .font(.caption2)
                    .foregroundColor(Theme.secondaryText)

                // Content
                content
                    .padding()
                    .background(isUser ? Theme.primary : Theme.surface)
                    .foregroundColor(isUser ? .black : .white)
                    .cornerRadius(12)

                // Artifacts
                if let artifacts = activity.artifacts {
                    ForEach(artifacts, id: \.self) { artifact in
                        ArtifactView(artifact: artifact)
                    }
                }
            }
            .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)

            if !isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    var isUser: Bool {
        return activity.originator == "user"
    }

    @ViewBuilder
    var content: some View {
        if let msg = activity.userMessaged {
            Text(msg.userMessage)
        } else if let msg = activity.agentMessaged {
            Text(msg.agentMessage)
        } else if let plan = activity.planGenerated?.plan {
            VStack(alignment: .leading, spacing: 10) {
                Text("Plan Generated")
                    .font(.headline)
                ForEach(plan.steps) { step in
                    HStack(alignment: .top) {
                        Text("\(step.index + 1).")
                            .fontWeight(.bold)
                        VStack(alignment: .leading) {
                            Text(step.title)
                                .fontWeight(.semibold)
                            Text(step.description)
                                .font(.caption)
                        }
                    }
                }
                Button("Approve Plan", action: onApprovePlan)
                    .padding(8)
                    .background(Theme.success)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        } else if let progress = activity.progressUpdated {
            VStack(alignment: .leading) {
                Text("Progress Update: \(progress.title)")
                    .fontWeight(.bold)
                if let desc = progress.description {
                    Text(desc)
                        .font(.caption)
                }
            }
        } else if activity.sessionCompleted != nil {
            Text("Session Completed")
                .fontWeight(.bold)
                .foregroundColor(.green)
        } else if let fail = activity.sessionFailed {
            Text("Session Failed: \(fail.reason)")
                .fontWeight(.bold)
                .foregroundColor(.red)
        } else {
            Text(activity.description ?? "Unknown Activity")
        }
    }
}
