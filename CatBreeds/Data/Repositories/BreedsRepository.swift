import Foundation

protocol BreedsRepository {
    func fetchBreeds(page: Int, limit: Int) async throws -> BreedsPage
}

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
            let remotePage = try await remoteDataSource.fetchBreeds(
                page: page,
                limit: limit
            )

            if page == 0 {
                try await localDataSource.saveBreeds(
                    remotePage.breeds,
                    page: page
                )

                let cachedBreeds = try await localDataSource.fetchBreeds(page: page)

                return BreedsPage(
                    breeds: cachedBreeds,
                    hasNextPage: remotePage.hasNextPage
                )
            }

            return remotePage
        } catch {
            guard page == 0 else {
                throw error
            }

            let cachedBreeds = try await localDataSource.fetchBreeds(page: page)

            guard !cachedBreeds.isEmpty else {
                throw error
            }

            return BreedsPage(
                breeds: cachedBreeds,
                hasNextPage: false
            )
        }
    }
}
