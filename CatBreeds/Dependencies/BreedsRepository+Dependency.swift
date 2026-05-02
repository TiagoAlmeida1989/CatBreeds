import ComposableArchitecture
import Foundation

private enum BreedsRepositoryKey: DependencyKey {
    static var liveValue: any BreedsRepository {
        @Dependency(\.catBreedsRemoteDataSource) var remote
        @Dependency(\.breedsLocalDataSource) var local
        return DefaultBreedsRepository(remoteDataSource: remote, localDataSource: local)
    }
}

extension DependencyValues {
    var breedsRepository: any BreedsRepository {
        get { self[BreedsRepositoryKey.self] }
        set { self[BreedsRepositoryKey.self] = newValue }
    }
}
