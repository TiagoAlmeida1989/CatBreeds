import CatBreedsCore
import ComposableArchitecture
import Foundation

struct BreedsClient {
    var fetchBreeds: @Sendable (_ page: Int, _ limit: Int) async throws -> BreedsPage
}

extension BreedsClient: DependencyKey {
    static var liveValue: BreedsClient {
        @Dependency(\.breedsRepository) var repository
        return BreedsClient(
            fetchBreeds: { try await repository.fetchBreeds(page: $0, limit: $1) }
        )
    }

    static let testValue = BreedsClient(
        fetchBreeds: { _, _ in throw APIError.networkUnavailable }
    )
}

extension DependencyValues {
    var breedsClient: BreedsClient {
        get { self[BreedsClient.self] }
        set { self[BreedsClient.self] = newValue }
    }
}
