#if DEBUG
import ComposableArchitecture

extension BreedsClient: TestDependencyKey {
    static let testValue = BreedsClient(
        fetchBreeds: { _, _ in throw APIError.networkUnavailable }
    )
}
#endif
