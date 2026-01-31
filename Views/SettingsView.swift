import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.primary)
                        .padding(.bottom, 20)

                    Text("Enter your Jules API Key")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.text)

                    Text("You can generate an API key from the Jules settings page.")
                        .font(.body)
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    JulesTextField(title: "API Key", text: $viewModel.apiKey, isSecure: true)
                        .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
