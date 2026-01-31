import SwiftUI

struct ContentView: View {
    @AppStorage("jules_api_key") var apiKey: String = ""

    var body: some View {
        if apiKey.isEmpty {
            SettingsView()
        } else {
            SessionListView()
        }
    }
}
