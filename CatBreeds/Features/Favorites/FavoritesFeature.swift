import ComposableArchitecture

struct FavoritesFeature: Reducer {
    struct State: Equatable {
        var breeds: [Breed] = []

        var averageLifespan: Double? {
            let values = breeds.compactMap(\.lifeSpan.average)
            guard !values.isEmpty else { return nil }
            return values.reduce(0, +) / Double(values.count)
        }
    }

    enum Action: Equatable {
        case favoriteButtonTapped(Breed.ID)
    }

    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case let .favoriteButtonTapped(id):
            state.breeds.removeAll { $0.id == id }
            return .none
        }
    }
}
