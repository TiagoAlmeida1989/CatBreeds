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

    enum Action: Equatable {}

    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {}
}
