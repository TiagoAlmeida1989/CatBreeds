import CatBreedsCore
import ComposableArchitecture

enum AppTab: Hashable {
    case breeds
    case favorites
}

@Reducer
struct AppFeature {

    @ObservableState
    struct State: Equatable {
        var selectedTab: AppTab = .breeds
        var breedsList = BreedsListFeature.State()
        var favorites = FavoritesFeature.State()
    }

    enum Action: Equatable {
        case selectedTabChanged(AppTab)
        case breedsList(BreedsListFeature.Action)
        case favorites(FavoritesFeature.Action)
        case task
        case favoritesLoaded(Result<[Breed], PersistenceError>)
    }

    @Dependency(\.favoritesPersistenceClient) var favoritesPersistenceClient

    var body: some Reducer<State, Action> {
        Scope(state: \.breedsList, action: \.breedsList) {
            BreedsListFeature()
        }

        Scope(state: \.favorites, action: \.favorites) {
            FavoritesFeature()
        }

        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none

            case let .breedsList(.favoriteButtonTapped(id)):
                state.favorites.breeds = state.breedsList.breeds.filter(\.isFavorite)

                guard let breed = state.breedsList.breeds.first(where: { $0.id == id }) else {
                    return .none
                }

                return .run { _ in
                    do {
                        if breed.isFavorite {
                            try await favoritesPersistenceClient.saveFavorite(breed)
                        } else {
                            try await favoritesPersistenceClient.removeFavorite(id)
                        }
                    } catch {
                        // UI is updated optimistically. A future step will revert
                        // state and surface an alert on persistence failure.
                    }
                }

            case .breedsList(.breedsResponse):
                syncFavoritesIntoBreedsList(state: &state)
                return .none

            case .breedsList:
                return .none

            case let .favorites(.favoriteButtonTapped(id)):
                state.breedsList.breeds = state.breedsList.breeds.map { breed in
                    var updatedBreed = breed
                    if breed.id == id { updatedBreed.isFavorite = false }
                    return updatedBreed
                }
                return .run { _ in
                    do {
                        try await favoritesPersistenceClient.removeFavorite(id)
                    } catch {
                        // UI is updated optimistically. A future step will revert
                        // state and surface an alert on persistence failure.
                    }
                }

            case .favorites:
                return .none

            case .task:
                return .run { send in
                    do {
                        let favorites = try await favoritesPersistenceClient.fetchFavorites()
                        await send(.favoritesLoaded(.success(favorites)))
                    } catch let error as PersistenceError {
                        await send(.favoritesLoaded(.failure(error)))
                    } catch {
                        await send(.favoritesLoaded(.failure(.fetchFailed)))
                    }
                }

            case let .favoritesLoaded(.success(favorites)):
                state.favorites.breeds = favorites
                syncFavoritesIntoBreedsList(state: &state)
                return .none

            case .favoritesLoaded(.failure):
                return .none
            }
        }
    }

    private func syncFavoritesIntoBreedsList(state: inout State) {
        let favoriteIDs = Set(state.favorites.breeds.map(\.id))

        state.breedsList.breeds = state.breedsList.breeds.map { breed in
            var updatedBreed = breed
            updatedBreed.isFavorite = favoriteIDs.contains(breed.id)
            return updatedBreed
        }
    }
}
