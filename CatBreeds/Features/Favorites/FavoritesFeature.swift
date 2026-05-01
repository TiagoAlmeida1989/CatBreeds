import ComposableArchitecture

@Reducer
struct FavoritesFeature {

    @ObservableState
    struct State: Equatable {
        var breeds: [Breed] = []

        var viewState: ViewState {
            breeds.isEmpty ? .empty : .content
        }

        var averageLifespan: Double? {
            let values = breeds.compactMap(\.lifeSpan.average)
            guard !values.isEmpty else { return nil }
            return values.reduce(0, +) / Double(values.count)
        }

        mutating func removeFavorite(id: Breed.ID) {
            breeds.removeAll { $0.id == id }
        }
    }

    enum ViewState: Equatable {
        case empty
        case content
    }

    enum Action: Equatable {
        case favoriteButtonTapped(Breed.ID)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .favoriteButtonTapped(id):
                state.removeFavorite(id: id)
                return .none
            }
        }
    }
}
