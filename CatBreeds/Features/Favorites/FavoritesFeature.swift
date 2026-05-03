import CatBreedsCore
import ComposableArchitecture

@Reducer
struct FavoritesFeature {

    @Reducer
    enum Path {
        case detail(BreedDetailFeature)
    }

    @ObservableState
    struct State: Equatable {
        var breeds: [Breed] = []

        var path = StackState<Path.State>()

        var viewState: ViewState {
            breeds.isEmpty ? .empty : .content
        }

        var averageLifespan: String? {
            breeds.averageLifespanFormatted
        }

        mutating func openDetail(for breed: Breed) {
            path.append(.detail(BreedDetailFeature.State(breed: breed, isFavorite: true)))
        }
    }

    enum ViewState: Equatable {
        case empty
        case content
    }

    enum Action: Equatable {
        case breedTapped(Breed)
        case favoriteButtonTapped(Breed.ID)
        case path(StackActionOf<Path>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .breedTapped(breed):
                state.openDetail(for: breed)
                return .none

            case .favoriteButtonTapped:
                return .none

            case let .path(.element(_, .detail(.delegate(.favoriteToggled(id))))):
                return .send(.favoriteButtonTapped(id))

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension FavoritesFeature.Path.State: Equatable {}
extension FavoritesFeature.Path.Action: Equatable {}
