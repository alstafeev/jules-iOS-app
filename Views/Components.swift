import SwiftUI

struct JulesTextField: View {
    var title: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.secondaryText)

            if isSecure {
                SecureField("", text: $text)
                    .padding()
                    .background(Theme.surface)
                    .cornerRadius(8)
                    .foregroundColor(Theme.text)
            } else {
                TextField("", text: $text)
                    .padding()
                    .background(Theme.surface)
                    .cornerRadius(8)
                    .foregroundColor(Theme.text)
            }
        }
    }
}

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.primary)
            .foregroundColor(.black) // Contrast
            .cornerRadius(8)
        }
        .disabled(isLoading)
    }
}
