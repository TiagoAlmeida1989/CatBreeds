import ComposableArchitecture

enum AppTab: Hashable {
    case breeds
    case favorites
}

struct AppFeature: Reducer {
    struct State: Equatable {
        var selectedTab: AppTab = .breeds
        var breedsList = BreedsListFeature.State()
        var favorites = FavoritesFeature.State()
    }

    enum Action: Equatable {
        case selectedTabChanged(AppTab)
        case breedsList(BreedsListFeature.Action)
        case favorites(FavoritesFeature.Action)
        case task
        case favoritesLoaded(Result<[Breed], PersistenceError>)
    }

    private let breedsListReducer = BreedsListFeature()
    private let favoritesReducer = FavoritesFeature()
    @Dependency(\.favoritesPersistenceClient) var favoritesPersistenceClient

    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case let .selectedTabChanged(tab):
            state.selectedTab = tab
            return .none

        case let .breedsList(breedsListAction):
            let effect = breedsListReducer
                .reduce(
                    into: &state.breedsList,
                    action: breedsListAction
                )
                .map(Action.breedsList)

            switch breedsListAction {
            case let .favoriteButtonTapped(id):
                state.favorites.breeds = state.breedsList.breeds.filter(\.isFavorite)

                guard let breed = state.breedsList.breeds.first(where: { $0.id == id }) else {
                    return effect
                }

                return .merge(
                    effect,
                    .run { _ in
                        if breed.isFavorite {
                            try await favoritesPersistenceClient.saveFavorite(breed)
                        } else {
                            try await favoritesPersistenceClient.removeFavorite(id)
                        }
                    }
                )

            case .breedsResponse(.success), .task, .loadNextPageIfNeeded, .searchTextChanged, .breedsResponse(.failure):
                let favoriteIDs = Set(state.favorites.breeds.map(\.id))

                state.breedsList.breeds = state.breedsList.breeds.map { breed in
                    var updatedBreed = breed
                    updatedBreed.isFavorite = favoriteIDs.contains(breed.id)
                    return updatedBreed
                }

                return effect
            }

        case let .favorites(favoritesAction):
            let effect = favoritesReducer
                .reduce(
                    into: &state.favorites,
                    action: favoritesAction
                )
                .map(Action.favorites)

            if case let .favoriteButtonTapped(id) = favoritesAction {
                state.breedsList.breeds = state.breedsList.breeds.map { breed in
                    var updatedBreed = breed
                    if breed.id == id {
                        updatedBreed.isFavorite = false
                    }
                    return updatedBreed
                }

                return .merge(
                    effect,
                    .run { _ in
                        try await favoritesPersistenceClient.removeFavorite(id)
                    }
                )
            }

            return effect
            
        case .task:
            return .run { send in
                do {
                    let favorites = try await favoritesPersistenceClient.fetchFavorites()
                    await send(.favoritesLoaded(.success(favorites)))
                } catch {
                    await send(.favoritesLoaded(.failure(.failed)))
                }
            }

        case let .favoritesLoaded(.success(favorites)):
            state.favorites.breeds = favorites

            state.breedsList.breeds = state.breedsList.breeds.map { breed in
                var updatedBreed = breed
                updatedBreed.isFavorite = favorites.contains { $0.id == breed.id }
                return updatedBreed
            }

            return .none

        case .favoritesLoaded(.failure):
            return .none
        }
    }
}
