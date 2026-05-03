#if DEBUG
import ComposableArchitecture
import Foundation

extension APIConfiguration: TestDependencyKey {
    static let testValue = APIConfiguration(
        baseURL: URL(string: "https://api.thecatapi.com/v1")!,
        apiKey: "test-api-key"
    )
}
#endif
