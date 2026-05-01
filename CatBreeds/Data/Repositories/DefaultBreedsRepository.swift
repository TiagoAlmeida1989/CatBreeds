import CatBreedsCore
import Foundation

struct DefaultBreedsRepository: BreedsRepository {
    private let remoteDataSource: CatBreedsRemoteDataSource
    private let localDataSource: BreedsLocalDataSource

    init(
        remoteDataSource: CatBreedsRemoteDataSource,
        localDataSource: BreedsLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchBreeds(page: Int, limit: Int) async throws -> BreedsPage {
        do {
            let remotePage = try await remoteDataSource.fetchBreeds(page: page, limit: limit)

            do {
                if page == 0 {
                    try await localDataSource.deleteAllBreeds()
                }
                try await localDataSource.saveBreeds(remotePage.breeds, page: page)
                let cachedBreeds = try await localDataSource.fetchBreeds(page: page)

                guard !cachedBreeds.isEmpty else { return remotePage }

                return BreedsPage(breeds: cachedBreeds, hasNextPage: remotePage.hasNextPage)
            } catch {
                return remotePage
            }

        } catch {
            let cachedBreeds = try await localDataSource.fetchBreeds(page: page)

            guard !cachedBreeds.isEmpty else { throw error }

            return BreedsPage(
                breeds: cachedBreeds,
                hasNextPage: cachedBreeds.count == limit
            )
        }
    }
}
