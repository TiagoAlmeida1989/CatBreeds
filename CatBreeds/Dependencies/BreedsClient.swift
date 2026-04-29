import ComposableArchitecture
import Foundation

struct BreedsClient {
    var fetchBreeds: @Sendable (_ page: Int, _ limit: Int) async throws -> BreedsPage
}

extension BreedsClient: DependencyKey {
    static let liveValue = BreedsClient(
        fetchBreeds: { page, limit in
            let apiClient = await DefaultAPIClient(
                httpClient: URLSessionHTTPClient(),
                requestBuilder: DefaultRequestBuilder()
            )

            let dataSource = await DefaultCatBreedsRemoteDataSource(
                apiClient: apiClient
            )

            return try await dataSource.fetchBreeds(
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
