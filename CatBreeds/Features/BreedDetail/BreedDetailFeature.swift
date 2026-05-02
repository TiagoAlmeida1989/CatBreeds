import CatBreedsCore
import ComposableArchitecture

@Reducer
struct BreedDetailFeature {

    @ObservableState
    struct State: Equatable {
        let breed: Breed
        var isFavorite: Bool
    }

    enum Action: Equatable {
        case favoriteButtonTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case favoriteToggled(Breed.ID)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .favoriteButtonTapped:
                state.isFavorite.toggle()
                return .send(.delegate(.favoriteToggled(state.breed.id)))

            case .delegate:
                return .none
            }
        }
    }
}
