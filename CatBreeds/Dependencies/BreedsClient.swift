import CatBreedsCore
import ComposableArchitecture
import Foundation

struct BreedsClient {
    var fetchBreeds: @Sendable (_ page: Int, _ limit: Int) async throws -> BreedsPage
}

extension BreedsClient: DependencyKey {
    static let liveValue: BreedsClient = {
        @Dependency(\.apiConfiguration) var apiConfiguration

        let repository = DefaultBreedsRepository(
            remoteDataSource: DefaultCatBreedsRemoteDataSource(
                apiClient: DefaultAPIClient(
                    httpClient: URLSessionHTTPClient(),
                    requestBuilder: DefaultRequestBuilder(configuration: apiConfiguration)
                )
            ),
            localDataSource: SwiftDataBreedsLocalDataSource(container: SwiftDataStack.shared)
        )

        return BreedsClient(
            fetchBreeds: { page, limit in
                try await repository.fetchBreeds(page: page, limit: limit)
            }
        )
    }()

    static let testValue = BreedsClient(
        fetchBreeds: { _, _ in
            throw APIError.requestFailed
        }
    )
}

extension DependencyValues {
    var breedsClient: BreedsClient {
        get { self[BreedsClient.self] }
        set { self[BreedsClient.self] = newValue }
    }
}
