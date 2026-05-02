import CatBreedsCore
import ComposableArchitecture

@Reducer
struct FavoritesFeature {

    @ObservableState
    struct State: Equatable {
        var breeds: [Breed] = []

        @Presents var detail: BreedDetailFeature.State?

        var viewState: ViewState {
            breeds.isEmpty ? .empty : .content
        }

        var averageLifespan: String? {
            breeds.averageLifespanFormatted
        }

        mutating func openDetail(for breed: Breed) {
            detail = BreedDetailFeature.State(
                breed: breed,
                isFavorite: true
            )
        }
    }

    enum ViewState: Equatable {
        case empty
        case content
    }

    enum Action: Equatable {
        case breedTapped(Breed)
        case favoriteButtonTapped(Breed.ID)
        case detail(PresentationAction<BreedDetailFeature.Action>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .breedTapped(breed):
                state.openDetail(for: breed)
                return .none

            case .favoriteButtonTapped:
                return .none

            case let .detail(.presented(.delegate(.favoriteToggled(id)))):
                return .send(.favoriteButtonTapped(id))

            case .detail:
                return .none
            }
        }
        .ifLet(\.$detail, action: \.detail) {
            BreedDetailFeature()
        }
    }
}
