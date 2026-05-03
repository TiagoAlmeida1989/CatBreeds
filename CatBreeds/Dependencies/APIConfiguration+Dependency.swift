import ComposableArchitecture
import Foundation

extension APIConfiguration: DependencyKey {
    static var liveValue: APIConfiguration {
        let info = Bundle.main.infoDictionary
        guard let rawURL = info?["CAT_API_BASE_URL"] as? String, !rawURL.isEmpty,
              let baseURL = URL(string: rawURL) else {
            fatalError("CAT_API_BASE_URL not found in Info.plist — ensure Config.xcconfig is present")
        }
        guard let apiKey = info?["CAT_API_KEY"] as? String, !apiKey.isEmpty else {
            fatalError("CAT_API_KEY not found in Info.plist — ensure Secrets.xcconfig is configured")
        }
        return APIConfiguration(baseURL: baseURL, apiKey: apiKey)
    }

    static let testValue = APIConfiguration(
        baseURL: URL(string: "https://api.thecatapi.com/v1")!,
        apiKey: "test-api-key"
    )
}

extension DependencyValues {
    var apiConfiguration: APIConfiguration {
        get { self[APIConfiguration.self] }
        set { self[APIConfiguration.self] = newValue }
    }
}
