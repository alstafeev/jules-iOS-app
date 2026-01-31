import SwiftUI

struct ArtifactView: View {
    let artifact: ArtifactWrapper

    var body: some View {
        VStack(alignment: .leading) {
            if let changeSet = artifact.changeSet {
                Text("Code Changes")
                    .font(.headline)
                    .foregroundColor(Theme.text)

                if let patch = changeSet.gitPatch {
                    Text(patch.suggestedCommitMessage ?? "No commit message")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)

                    ScrollView(.horizontal) {
                        Text(patch.unidiffPatch ?? "No diff")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.green) // Simple coloring
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                }
            }

            if let bash = artifact.bashOutput {
                Text("Command Output")
                    .font(.headline)
                    .foregroundColor(Theme.text)

                VStack(alignment: .leading) {
                    Text("$ \(bash.command)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.yellow)

                    Text(bash.output)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black)
                .cornerRadius(8)
            }

            if let media = artifact.media {
                Text("Media Artifact")
                     .font(.headline)
                     .foregroundColor(Theme.text)
                Text(media.mimeType)
            }
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(12)
    }
}
