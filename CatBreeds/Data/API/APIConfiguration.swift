import ComposableArchitecture
import Foundation

struct APIConfiguration: Equatable {
    let baseURL: URL
    let apiKey: String
}

extension APIConfiguration: DependencyKey {
    static let liveValue = APIConfiguration(
        baseURL: URL(string: "https://api.thecatapi.com/v1")!,
        apiKey: GeneratedSecrets.catAPIKey
    )

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
