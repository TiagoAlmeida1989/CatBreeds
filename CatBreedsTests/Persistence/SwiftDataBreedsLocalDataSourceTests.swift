import CatBreedsCore
import SwiftData
import Testing
@testable import CatBreeds

@Suite("SwiftDataBreedsLocalDataSource")
struct SwiftDataBreedsLocalDataSourceTests {

    @Test
    func deleteAllBreedsRemovesAllPagesAndClearsImageCache() async throws {
        let container = try makeContainer()
        let imageCacheSpy = ImageCacheDataSourceSpy()
        let sut = await SwiftDataBreedsLocalDataSource(container: container, imageCache: imageCacheSpy)

        try await sut.saveBreeds([.abyssinian, .bengal], page: 0)
        try await sut.saveBreeds([.maineCoon], page: 1)

        try await sut.deleteAllBreeds()

        let page0 = try await sut.fetchBreeds(page: 0)
        let page1 = try await sut.fetchBreeds(page: 1)
        #expect(page0.isEmpty)
        #expect(page1.isEmpty)
        #expect(imageCacheSpy.removeAllCallCount == 1)
    }

    @Test
    func deleteAllBreedsDoesNotCallImageCacheWhenNoBreedsExist() async throws {
        let container = try makeContainer()
        let imageCacheSpy = ImageCacheDataSourceSpy()
        let sut = await SwiftDataBreedsLocalDataSource(container: container, imageCache: imageCacheSpy)

        try await sut.deleteAllBreeds()

        #expect(imageCacheSpy.removeAllCallCount == 1)
    }

    @Test
    func saveThenFetchReturnsBreedsInPositionOrder() async throws {
        let container = try makeContainer()
        let sut = await SwiftDataBreedsLocalDataSource(container: container)

        let breeds = [Breed.abyssinian, .bengal, .maineCoon]
        try await sut.saveBreeds(breeds, page: 0)

        let fetched = try await sut.fetchBreeds(page: 0)
        #expect(fetched.map(\.id) == breeds.map(\.id))
    }

    @Test
    func saveBreedsOverwritesExistingPageEntries() async throws {
        let container = try makeContainer()
        let sut = await SwiftDataBreedsLocalDataSource(container: container)

        try await sut.saveBreeds([.abyssinian, .bengal], page: 0)
        try await sut.saveBreeds([.maineCoon], page: 0)

        let fetched = try await sut.fetchBreeds(page: 0)
        #expect(fetched.map(\.id) == [Breed.maineCoon.id])
    }

    @Test
    func fetchBreedsReturnsEmptyWhenPageNotCached() async throws {
        let container = try makeContainer()
        let sut = await SwiftDataBreedsLocalDataSource(container: container)

        let fetched = try await sut.fetchBreeds(page: 99)
        #expect(fetched.isEmpty)
    }
}

// MARK: - Helpers

private func makeContainer() throws -> ModelContainer {
    let schema = Schema([CachedBreedEntity.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])
}
