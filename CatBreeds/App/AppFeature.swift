import ComposableArchitecture

enum AppTab: Hashable {
    case breeds
    case favorites
}

struct AppFeature: Reducer {
    struct State: Equatable {
        var selectedTab: AppTab = .breeds
        var breedsList = BreedsListFeature.State()
    }

    enum Action: Equatable {
        case selectedTabChanged(AppTab)
        case breedsList(BreedsListFeature.Action)
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
            return breedsListReducer
                .reduce(
                    into: &state.breedsList,
                    action: breedsListAction
                )
                .map(Action.breedsList)
        }
    }
}
