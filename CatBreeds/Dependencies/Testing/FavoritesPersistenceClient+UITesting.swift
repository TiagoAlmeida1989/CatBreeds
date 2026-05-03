#if DEBUG
import CatBreedsCore

extension FavoritesPersistenceClient {
    static let uiTestingValue: FavoritesPersistenceClient = {
        let store = InMemoryFavoritesStore()
        return FavoritesPersistenceClient(
            fetchFavorites: { await store.fetchAll() },
            saveFavorite: { breed in await store.save(breed) },
            removeFavorite: { id in await store.remove(id) }
        )
    }()
}

private actor InMemoryFavoritesStore {
    private var favorites: [Breed] = []

    func fetchAll() -> [Breed] { favorites }

    func save(_ breed: Breed) {
        favorites.removeAll { $0.id == breed.id }
        favorites.append(breed)
    }

    func remove(_ id: Breed.ID) {
        favorites.removeAll { $0.id == id }
    }
}
#endif
