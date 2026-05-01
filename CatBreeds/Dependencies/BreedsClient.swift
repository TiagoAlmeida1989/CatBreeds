import ComposableArchitecture
import Foundation

struct BreedsClient {
    var fetchBreeds: @Sendable (_ page: Int, _ limit: Int) async throws -> BreedsPage
}

extension BreedsClient: DependencyKey {
    static let liveValue: BreedsClient = {
        @Dependency(\.apiConfiguration) var apiConfiguration

        return BreedsClient(
            fetchBreeds: { page, limit in
                let apiClient = await DefaultAPIClient(
                    httpClient: URLSessionHTTPClient(),
                    requestBuilder: DefaultRequestBuilder(configuration: apiConfiguration)
                )

                let remoteDataSource = await DefaultCatBreedsRemoteDataSource(
                    apiClient: apiClient
                )

                let container = await MainActor.run { SwiftDataStack.shared }
                let localDataSource = await SwiftDataBreedsLocalDataSource(container: container)

                let repository = await DefaultBreedsRepository(
                    remoteDataSource: remoteDataSource,
                    localDataSource: localDataSource
                )

                return try await repository.fetchBreeds(page: page, limit: limit)
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
