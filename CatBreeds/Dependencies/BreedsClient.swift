import ComposableArchitecture
import Foundation

struct BreedsClient {
    var fetchBreeds: @Sendable (_ page: Int, _ limit: Int) async throws -> BreedsPage
}

extension BreedsClient: DependencyKey {
    static let liveValue = BreedsClient(
        fetchBreeds: { page, limit in
            let apiClient = DefaultAPIClient(
                httpClient: URLSessionHTTPClient(),
                requestBuilder: DefaultRequestBuilder()
            )

            let remoteDataSource = DefaultCatBreedsRemoteDataSource(
                apiClient: apiClient
            )

            let container = await MainActor.run { SwiftDataStack.shared }
            let localDataSource = SwiftDataBreedsLocalDataSource(container: container)

            let repository = DefaultBreedsRepository(
                remoteDataSource: remoteDataSource,
                localDataSource: localDataSource
            )

            return try await repository.fetchBreeds(
                page: page,
                limit: limit
            )
        }
    )

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
