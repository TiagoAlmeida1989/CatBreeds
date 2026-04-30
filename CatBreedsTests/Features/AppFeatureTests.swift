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
        let favoriteAbyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: true)

        let spy = FavoritesPersistenceSpy(fetchResult: .success([favoriteAbyssinian]))
        let store = makeStore(
            breedsListBreeds: [abyssinian, bengal],
            spy: spy
        )

        await store.send(.task)

        await store.receive(.favoritesLoaded(.success([favoriteAbyssinian]))) {
            $0.favorites.breeds = [favoriteAbyssinian]
            $0.breedsList.breeds[0].isFavorite = true
        }

        #expect(await spy.fetchFavoritesCallCount() == 1)
    }

    @Test
    func taskFailureKeepsCurrentState() async {
        let spy = FavoritesPersistenceSpy(fetchResult: .failure(.failed))
        let store = makeStore(
            breedsListBreeds: [.abyssinian, .bengal],
            favoritesBreeds: [.maineCoon],
            spy: spy
        )

        await store.send(.task)
        await store.receive(.favoritesLoaded(.failure(.failed)))

        #expect(await spy.fetchFavoritesCallCount() == 1)
        #expect(store.state.breedsList.breeds == [.abyssinian, .bengal])
        #expect(store.state.favorites.breeds == [.maineCoon])
    }

    // MARK: - Breeds List Integration

    @Test
    func togglingBreedFavoriteOnAddsItToFavoritesAndPersistsIt() async {
        let abyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: false)
        let favoritedAbyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: true)
        let spy = FavoritesPersistenceSpy()
        let store = makeStore(
            breedsListBreeds: [abyssinian],
            spy: spy
        )

        await store.send(.breedsList(.favoriteButtonTapped(abyssinian.id))) {
            $0.breedsList.breeds = [favoritedAbyssinian]
            $0.favorites.breeds = [favoritedAbyssinian]
        }

        await store.finish()

        #expect(await spy.savedFavorites() == [favoritedAbyssinian])
        #expect(await spy.removedFavoriteIDs() == [])
    }

    @Test
    func togglingBreedFavoriteOffRemovesItFromFavoritesAndPersistsRemoval() async {
        let favoriteAbyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: true)
        let unfavoritedAbyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: false)
        let spy = FavoritesPersistenceSpy()
        let store = makeStore(
            breedsListBreeds: [favoriteAbyssinian],
            favoritesBreeds: [favoriteAbyssinian],
            spy: spy
        )

        await store.send(.breedsList(.favoriteButtonTapped(favoriteAbyssinian.id))) {
            $0.breedsList.breeds = [unfavoritedAbyssinian]
            $0.favorites.breeds = []
        }

        await store.finish()

        #expect(await spy.savedFavorites() == [])
        #expect(await spy.removedFavoriteIDs() == [favoriteAbyssinian.id])
    }

    @Test
    func breedsListResponsePreservesLoadedFavorites() async {
        let favoriteAbyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: true)
        let page = makeBreedsPage(
            breeds: [
                Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: false),
                Breed.makeBreed(id: "beng", name: "Bengal", isFavorite: false)
            ],
            hasNextPage: true
        )
        let store = makeStore(favoritesBreeds: [favoriteAbyssinian])

        await store.send(.breedsList(.breedsResponse(.success(page), .initial))) {
            $0.breedsList.breeds = page.breeds
            $0.breedsList.breeds[0].isFavorite = true
            $0.breedsList.nextPage = 1
            $0.breedsList.canLoadMore = true
            $0.breedsList.loadState = .idle
        }
    }

    // MARK: - Favorites Integration

    @Test
    func removingFavoriteFromFavoritesFeatureUpdatesBreedsListAndPersistsRemoval() async {
        let favoriteAbyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: true)
        let unfavoritedAbyssinian = Breed.makeBreed(id: "abys", name: "Abyssinian", isFavorite: false)
        let spy = FavoritesPersistenceSpy()
        let store = makeStore(
            breedsListBreeds: [favoriteAbyssinian, .bengal],
            favoritesBreeds: [favoriteAbyssinian],
            spy: spy
        )

        await store.send(.favorites(.favoriteButtonTapped(favoriteAbyssinian.id))) {
            $0.favorites.breeds = []
            $0.breedsList.breeds = [unfavoritedAbyssinian, .bengal]
        }

        await store.finish()

        #expect(await spy.removedFavoriteIDs() == [favoriteAbyssinian.id])
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

    func fetchFavoritesCallCount() -> Int {
        fetchFavoritesCallCountValue
    }

    func savedFavorites() -> [Breed] {
        savedFavoritesValue
    }

    func removedFavoriteIDs() -> [String] {
        removedFavoriteIDsValue
    }
}

