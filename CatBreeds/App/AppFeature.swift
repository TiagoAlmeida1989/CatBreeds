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

        case .favorites:
            return .none
        }
    }
}
