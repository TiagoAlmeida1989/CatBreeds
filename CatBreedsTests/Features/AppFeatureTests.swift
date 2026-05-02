import CatBreedsCore
import ComposableArchitecture
import Testing
@testable import CatBreeds

@MainActor
struct AppFeatureTests {

    // MARK: - Tab Selection

    @Test
    func selectedTabChanged() async {
        let store = makeStore()

        await store.send(.selectedTabChanged(.favorites)) {
            $0.selectedTab = .favorites
        }

        await store.send(.selectedTabChanged(.breeds)) {
            $0.selectedTab = .breeds
        }
    }

    // MARK: - Loading Favorites

    @Test
    func taskLoadsFavoritesAndSyncsThemIntoBreedsList() async {
        let abyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian")
        let bengal = Breed.makeBreed(id: "beng", name: "Bengal")

        let spy = FavoritesPersistenceSpy(fetchResult: .success([abyssinian]))
        let store = makeStore(
            breedsListBreeds: [abyssinian, bengal],
            spy: spy
        )

        await store.send(.task)

        await store.receive(.favoritesLoaded(.success([abyssinian]))) {
            $0.favorites.breeds = [abyssinian]
            $0.favoriteIDs = [abyssinian.id]
            $0.breedsList.favoriteIDs = [abyssinian.id]
        }

        #expect(await spy.fetchFavoritesCallCount() == 1)
    }

    @Test
    func taskFailureKeepsCurrentState() async {
        let spy = FavoritesPersistenceSpy(fetchResult: .failure(.fetchFailed))
        let store = makeStore(
            breedsListBreeds: [.abyssinian, .bengal],
            favoritesBreeds: [.maineCoon],
            spy: spy
        )

        await store.send(.task)
        await store.receive(.favoritesLoaded(.failure(.fetchFailed)))

        #expect(await spy.fetchFavoritesCallCount() == 1)
        #expect(store.state.breedsList.breeds == [.abyssinian, .bengal])
        #expect(store.state.favorites.breeds == [.maineCoon])
    }

    // MARK: - Breeds List Integration

    @Test
    func togglingBreedFavoriteOnAddsItToFavoritesAndPersistsIt() async {
        let abyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian")
        let spy = FavoritesPersistenceSpy()
        let store = makeStore(
            breedsListBreeds: [abyssinian],
            spy: spy
        )

        await store.send(.breedsList(.favoriteButtonTapped(abyssinian.id))) {
            $0.breedsList.favoriteIDs = [abyssinian.id]
            $0.favoriteIDs = [abyssinian.id]
            $0.favorites.breeds = [abyssinian]
        }

        await store.finish()

        #expect(await spy.savedFavorites() == [abyssinian])
        #expect(await spy.removedFavoriteIDs() == [])
    }

    @Test
    func togglingBreedFavoriteOffRemovesItFromFavoritesAndPersistsRemoval() async {
        let abyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian")
        let spy = FavoritesPersistenceSpy()
        let store = makeStore(
            breedsListBreeds: [abyssinian],
            favoritesBreeds: [abyssinian],
            spy: spy
        )

        await store.send(.breedsList(.favoriteButtonTapped(abyssinian.id))) {
            $0.breedsList.favoriteIDs = []
            $0.favoriteIDs = []
            $0.favorites.breeds = []
        }

        await store.finish()

        #expect(await spy.savedFavorites() == [])
        #expect(await spy.removedFavoriteIDs() == [abyssinian.id])
    }

    @Test
    func breedsListResponseSyncsFavoriteIDsIntoBreedsList() async {
        let abyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian")
        let bengal = Breed.makeBreed(id: "beng", name: "Bengal")
        let page = makeBreedsPage(breeds: [abyssinian, bengal], hasNextPage: true)
        let store = makeStore(favoritesBreeds: [abyssinian])

        await store.send(.breedsList(.breedsResponse(.success(page), .initial))) {
            $0.breedsList.breeds = page.breeds
            $0.breedsList.favoriteIDs = [abyssinian.id]
            $0.breedsList.nextPage = 1
            $0.breedsList.canLoadMore = true
            $0.breedsList.loadState = .idle
        }
    }

    // MARK: - Detail Delegate Integration

    @Test
    func favoriteToggledFromDetailInBreedsListAddsToFavorites() async {
        let abyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian")
        let spy = FavoritesPersistenceSpy()
        var state = AppFeature.State()
        state.breedsList.breeds = [abyssinian]
        state.breedsList.detail = BreedDetailFeature.State(breed: abyssinian, isFavorite: false)

        let store = TestStore(initialState: state) { AppFeature() }
        store.dependencies.favoritesPersistenceClient.saveFavorite = { breed in
            try await spy.saveFavorite(breed)
        }
        store.dependencies.favoritesPersistenceClient.removeFavorite = { id in
            try await spy.removeFavorite(id)
        }

        await store.send(.breedsList(.detail(.presented(.favoriteButtonTapped)))) {
            $0.breedsList.detail?.isFavorite = true
        }

        await store.receive(.breedsList(.detail(.presented(.delegate(.favoriteToggled(abyssinian.id))))))

        await store.receive(.breedsList(.favoriteButtonTapped(abyssinian.id))) {
            $0.breedsList.favoriteIDs = [abyssinian.id]
            $0.favoriteIDs = [abyssinian.id]
            $0.favorites.breeds = [abyssinian]
        }

        await store.finish()
        #expect(await spy.savedFavorites() == [abyssinian])
    }

    @Test
    func favoriteToggledFromDetailInFavoritesRemovesFromFavorites() async {
        let abyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian")
        let spy = FavoritesPersistenceSpy()

        var state = AppFeature.State()
        state.favorites.breeds = [abyssinian]
        state.favoriteIDs = [abyssinian.id]
        state.breedsList.favoriteIDs = [abyssinian.id]
        state.favorites.detail = BreedDetailFeature.State(breed: abyssinian, isFavorite: true)

        let store = TestStore(initialState: state) { AppFeature() }
        store.dependencies.favoritesPersistenceClient.saveFavorite = { _ in }
        store.dependencies.favoritesPersistenceClient.removeFavorite = { id in
            try await spy.removeFavorite(id)
        }

        await store.send(.favorites(.detail(.presented(.favoriteButtonTapped)))) {
            $0.favorites.detail?.isFavorite = false
        }

        await store.receive(.favorites(.detail(.presented(.delegate(.favoriteToggled(abyssinian.id))))))

        await store.receive(.favorites(.favoriteButtonTapped(abyssinian.id))) {
            $0.favorites.breeds = []
            $0.favoriteIDs = []
            $0.breedsList.favoriteIDs = []
        }

        await store.finish()
        #expect(await spy.removedFavoriteIDs() == [abyssinian.id])
    }

    // MARK: - Favorites Integration

    @Test
    func removingFavoriteFromFavoritesFeatureUpdatesBreedsListAndPersistsRemoval() async {
        let abyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian")
        let spy = FavoritesPersistenceSpy()
        let store = makeStore(
            breedsListBreeds: [abyssinian, .bengal],
            favoritesBreeds: [abyssinian],
            spy: spy
        )

        await store.send(.favorites(.favoriteButtonTapped(abyssinian.id))) {
            $0.favorites.breeds = []
            $0.favoriteIDs = []
            $0.breedsList.favoriteIDs = []
        }

        await store.finish()

        #expect(await spy.removedFavoriteIDs() == [abyssinian.id])
    }
}

private extension AppFeatureTests {
    func makeStore(
        selectedTab: AppTab = .breeds,
        breedsListBreeds: [Breed] = [],
        favoritesBreeds: [Breed] = [],
        spy: FavoritesPersistenceSpy = FavoritesPersistenceSpy()
    ) -> TestStore<AppFeature.State, AppFeature.Action> {
        var state = AppFeature.State()
        state.selectedTab = selectedTab
        state.breedsList.breeds = breedsListBreeds
        state.favorites.breeds = favoritesBreeds
        state.favoriteIDs = Set(favoritesBreeds.map(\.id))
        state.breedsList.favoriteIDs = state.favoriteIDs

        let store = TestStore(initialState: state) {
            AppFeature()
        }

        store.dependencies.favoritesPersistenceClient.fetchFavorites = {
            try await spy.fetchFavorites()
        }
        store.dependencies.favoritesPersistenceClient.saveFavorite = { breed in
            try await spy.saveFavorite(breed)
        }
        store.dependencies.favoritesPersistenceClient.removeFavorite = { id in
            try await spy.removeFavorite(id)
        }

        return store
    }
}

private actor FavoritesPersistenceSpy {
    private let fetchResult: Result<[Breed], PersistenceError>

    private var fetchFavoritesCallCountValue = 0
    private var savedFavoritesValue: [Breed] = []
    private var removedFavoriteIDsValue: [String] = []

    init(fetchResult: Result<[Breed], PersistenceError> = .success([])) {
        self.fetchResult = fetchResult
    }

    func fetchFavorites() async throws -> [Breed] {
        fetchFavoritesCallCountValue += 1
        return try fetchResult.get()
    }

    func saveFavorite(_ breed: Breed) async throws {
        savedFavoritesValue.append(breed)
    }

    func removeFavorite(_ id: String) async throws {
        removedFavoriteIDsValue.append(id)
    }

    func fetchFavoritesCallCount() -> Int { fetchFavoritesCallCountValue }
    func savedFavorites() -> [Breed] { savedFavoritesValue }
    func removedFavoriteIDs() -> [String] { removedFavoriteIDsValue }
}
