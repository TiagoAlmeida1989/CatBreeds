import ComposableArchitecture
import Foundation

private enum CatBreedsRemoteDataSourceKey: DependencyKey {
    static var liveValue: any CatBreedsRemoteDataSource {
        @Dependency(\.apiConfiguration) var configuration
        return DefaultCatBreedsRemoteDataSource(
            apiClient: DefaultAPIClient(
                httpClient: URLSessionHTTPClient(),
                requestBuilder: DefaultRequestBuilder(configuration: configuration)
            )
        )
    }
}

extension DependencyValues {
    var catBreedsRemoteDataSource: any CatBreedsRemoteDataSource {
        get { self[CatBreedsRemoteDataSourceKey.self] }
        set { self[CatBreedsRemoteDataSourceKey.self] = newValue }
    }
}
