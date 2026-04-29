import ComposableArchitecture

enum AppTab: Hashable {
    case breeds
    case favorites
}

struct AppFeature: Reducer {
    struct State: Equatable {
        var selectedTab: AppTab = .breeds
    }

    enum Action: Equatable {
        case selectedTabChanged(AppTab)
    }

    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case let .selectedTabChanged(tab):
            state.selectedTab = tab
            return .none
        }
    }
}
