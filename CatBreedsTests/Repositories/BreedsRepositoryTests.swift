import CatBreedsCore
import Testing
@testable import CatBreeds

@Suite("BreedsRepository")
struct BreedsRepositoryTests {
    @Test
    func fetchBreedsForFirstPageDeletesAllCachesThenReturnsCachedPage() async throws {
        let remotePage = makeBreedsPage(breeds: [.abyssinian, .bengal], hasNextPage: true)
        let cachedBreeds = [
            Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: true),
            Breed.makeBreed(id: "beng", name: "Bengal", isFavorite: false)
        ]
        let remote = RemoteBreedsDataSourceSpy(result: .success(remotePage))
        let local = LocalBreedsDataSourceSpy(fetchResult: .success(cachedBreeds))
        let repository = makeRepository(remote: remote, local: local)

        let result = try await repository.fetchBreeds(page: 0, limit: 2)

        #expect(result == makeBreedsPage(breeds: cachedBreeds, hasNextPage: true))
        #expect(await remote.fetchCalls == [FetchCall(page: 0, limit: 2)])
        #expect(await local.deleteAllCallCount == 1)
        #expect(await local.savedCalls == [SaveCall(breeds: remotePage.breeds, page: 0)])
        #expect(await local.fetchCalls == [0])
    }

    @Test
    func fetchBreedsForFirstPageReturnsRemotePageWhenLocalSaveFails() async throws {
        let remotePage = makeBreedsPage(breeds: [.abyssinian, .bengal], hasNextPage: true)
        let remote = RemoteBreedsDataSourceSpy(result: .success(remotePage))
        let local = LocalBreedsDataSourceSpy(
            saveError: TestError.localFailed,
            fetchResult: .success([])
        )
        let repository = makeRepository(remote: remote, local: local)

        let result = try await repository.fetchBreeds(page: 0, limit: 2)

        #expect(result == remotePage)
        #expect(await local.deleteAllCallCount == 1)
        #expect(await local.savedCalls == [SaveCall(breeds: remotePage.breeds, page: 0)])
        #expect(await local.fetchCalls == [])
    }

    @Test
    func fetchBreedsForNextPageReturnsCachedPageAfterSavingRemotePage() async throws {
        let remotePage = makeBreedsPage(breeds: [.maineCoon], hasNextPage: false)
        let cachedBreeds: [Breed] = [.maineCoon]
        let remote = RemoteBreedsDataSourceSpy(result: .success(remotePage))
        let local = LocalBreedsDataSourceSpy(fetchResult: .success(cachedBreeds))
        let repository = makeRepository(remote: remote, local: local)

        let result = try await repository.fetchBreeds(page: 1, limit: 2)

        #expect(result == remotePage)
        #expect(await remote.fetchCalls == [FetchCall(page: 1, limit: 2)])
        #expect(await local.deleteAllCallCount == 0)
        #expect(await local.savedCalls == [SaveCall(breeds: remotePage.breeds, page: 1)])
        #expect(await local.fetchCalls == [1])
    }

    @Test
    func fetchBreedsForFirstPageFallsBackToCacheWhenRemoteFails() async throws {
        let cachedBreeds: [Breed] = [.abyssinian, .bengal]
        let remote = RemoteBreedsDataSourceSpy(result: .failure(APIError.networkUnavailable))
        let local = LocalBreedsDataSourceSpy(fetchResult: .success(cachedBreeds))
        let repository = makeRepository(remote: remote, local: local)

        let result = try await repository.fetchBreeds(page: 0, limit: 2)

        #expect(result == makeBreedsPage(breeds: cachedBreeds, hasNextPage: true))
        #expect(await remote.fetchCalls == [FetchCall(page: 0, limit: 2)])
        #expect(await local.deleteAllCallCount == 0)
        #expect(await local.savedCalls == [])
        #expect(await local.fetchCalls == [0])
    }

    @Test
    func fetchBreedsForNextPageFallsBackToCacheWhenRemoteFails() async throws {
        let cachedBreeds: [Breed] = [.maineCoon]
        let remote = RemoteBreedsDataSourceSpy(result: .failure(APIError.networkUnavailable))
        let local = LocalBreedsDataSourceSpy(fetchResult: .success(cachedBreeds))
        let repository = makeRepository(remote: remote, local: local)

        let result = try await repository.fetchBreeds(page: 1, limit: 2)

        #expect(result == makeBreedsPage(breeds: cachedBreeds, hasNextPage: false))
        #expect(await local.deleteAllCallCount == 0)
        #expect(await local.savedCalls == [])
        #expect(await local.fetchCalls == [1])
    }

    @Test
    func fetchBreedsForFirstPageFallbackCacheSetsHasNextPageToFalseWhenCacheIsSmallerThanLimit() async throws {
        let cachedBreeds: [Breed] = [.abyssinian]
        let remote = RemoteBreedsDataSourceSpy(result: .failure(APIError.networkUnavailable))
        let local = LocalBreedsDataSourceSpy(fetchResult: .success(cachedBreeds))
        let repository = makeRepository(remote: remote, local: local)

        let result = try await repository.fetchBreeds(page: 0, limit: 2)

        #expect(result == makeBreedsPage(breeds: cachedBreeds, hasNextPage: false))
    }

    @Test
    func fetchBreedsForFirstPageThrowsRemoteErrorWhenRemoteFailsAndCacheIsEmpty() async {
        let remote = RemoteBreedsDataSourceSpy(result: .failure(APIError.networkUnavailable))
        let local = LocalBreedsDataSourceSpy(fetchResult: .success([]))
        let repository = makeRepository(remote: remote, local: local)

        do {
            _ = try await repository.fetchBreeds(page: 0, limit: 2)
            Issue.record("Expected repository to throw")
        } catch {
            #expect(error as? APIError == .networkUnavailable)
        }
    }

    @Test
    func fetchBreedsForNextPageThrowsRemoteErrorWhenRemoteFailsAndCacheIsEmpty() async {
        let remote = RemoteBreedsDataSourceSpy(result: .failure(APIError.networkUnavailable))
        let local = LocalBreedsDataSourceSpy(fetchResult: .success([]))
        let repository = makeRepository(remote: remote, local: local)

        do {
            _ = try await repository.fetchBreeds(page: 1, limit: 2)
            Issue.record("Expected repository to throw")
        } catch {
            #expect(error as? APIError == .networkUnavailable)
        }
    }
}

// MARK: - Helpers

private func makeRepository(
    remote: CatBreedsRemoteDataSource,
    local: BreedsLocalDataSource
) -> DefaultBreedsRepository {
    DefaultBreedsRepository(
        remoteDataSource: remote,
        localDataSource: local
    )
}

private struct FetchCall: Equatable, Sendable {
    let page: Int
    let limit: Int
}

private struct SaveCall: Equatable, Sendable {
    let breeds: [Breed]
    let page: Int
}

private enum TestError: Error, Equatable {
    case localFailed
}

private actor RemoteBreedsDataSourceSpy: CatBreedsRemoteDataSource {
    private let result: Result<BreedsPage, Error>
    private var _fetchCalls: [FetchCall] = []

    init(result: Result<BreedsPage, Error>) {
        self.result = result
    }

    var fetchCalls: [FetchCall] { _fetchCalls }

    func fetchBreeds(page: Int, limit: Int) async throws -> BreedsPage {
        _fetchCalls.append(FetchCall(page: page, limit: limit))
        return try result.get()
    }
}

private actor LocalBreedsDataSourceSpy: BreedsLocalDataSource {
    private let saveError: Error?
    private let fetchResult: Result<[Breed], Error>
    private var _savedCalls: [SaveCall] = []
    private var _fetchCalls: [Int] = []
    private var _deleteAllCallCount = 0

    init(
        saveError: Error? = nil,
        fetchResult: Result<[Breed], Error>
    ) {
        self.saveError = saveError
        self.fetchResult = fetchResult
    }

    var savedCalls: [SaveCall] { _savedCalls }
    var fetchCalls: [Int] { _fetchCalls }
    var deleteAllCallCount: Int { _deleteAllCallCount }

    func saveBreeds(_ breeds: [Breed], page: Int) async throws {
        _savedCalls.append(SaveCall(breeds: breeds, page: page))
        if let saveError { throw saveError }
    }

    func fetchBreeds(page: Int) async throws -> [Breed] {
        _fetchCalls.append(page)
        return try fetchResult.get()
    }

    func deleteAllBreeds() async throws {
        _deleteAllCallCount += 1
    }
}

