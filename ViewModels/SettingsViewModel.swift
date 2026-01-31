import Foundation
import Combine

public class SettingsViewModel: ObservableObject {
    @Published public var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "jules_api_key")
            APIService.shared.apiKey = apiKey
        }
    }

    public init() {
        self.apiKey = UserDefaults.standard.string(forKey: "jules_api_key") ?? ""
        APIService.shared.apiKey = self.apiKey
    }
}
