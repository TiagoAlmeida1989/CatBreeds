#if DEBUG
import ComposableArchitecture

extension FavoritesPersistenceClient: TestDependencyKey {
    static let testValue = FavoritesPersistenceClient(
        fetchFavorites: { [] },
        saveFavorite: { _ in },
        removeFavorite: { _ in }
    )
}
#endif
