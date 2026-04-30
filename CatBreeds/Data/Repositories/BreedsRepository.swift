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

            guard page == 0 else {
                return remotePage
            }

            do {
                try await localDataSource.saveBreeds(
                    remotePage.breeds,
                    page: page
                )

                let cachedBreeds = try await localDataSource.fetchBreeds(page: page)

                guard !cachedBreeds.isEmpty else {
                    return remotePage
                }

                let result = BreedsPage(breeds: cachedBreeds, hasNextPage: remotePage.hasNextPage)
                return result
            } catch {
                return remotePage
            }

        } catch {
            guard page == 0 else {
                throw error
            }

            let cachedBreeds = try await localDataSource.fetchBreeds(page: page)

            guard !cachedBreeds.isEmpty else {
                throw error
            }

            let hasNextPage = cachedBreeds.count == limit

            return BreedsPage(
                breeds: cachedBreeds,
                hasNextPage: hasNextPage
            )
        }
    }
}
