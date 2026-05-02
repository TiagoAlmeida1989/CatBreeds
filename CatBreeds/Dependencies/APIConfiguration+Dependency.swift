import ComposableArchitecture
import Foundation

extension APIConfiguration: DependencyKey {
    static var liveValue: APIConfiguration {
        guard let apiKey = Bundle.main.infoDictionary?["CAT_API_KEY"] as? String, !apiKey.isEmpty else {
            fatalError("CAT_API_KEY not found in Info.plist — ensure Secrets.xcconfig is configured")
        }
        return APIConfiguration(
            baseURL: URL(string: "https://api.thecatapi.com/v1")!,
            apiKey: apiKey
        )
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
