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
    }

    private let breedsListReducer = BreedsListFeature()
    private let favoritesReducer = FavoritesFeature()

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

            state.favorites.breeds = state.breedsList.breeds.filter(\.isFavorite)

            return effect

        case let .favorites(favoritesAction):
            let effect = favoritesReducer
                .reduce(
                    into: &state.favorites,
                    action: favoritesAction
                )
                .map(Action.favorites)

            state.breedsList.breeds = state.breedsList.breeds.map { breed in
                var updatedBreed = breed
                updatedBreed.isFavorite = state.favorites.breeds.contains {
                    $0.id == breed.id
                }
                return updatedBreed
            }

            return effect
        }
    }
}
