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
        var favoriteIDs: Set<Breed.ID> = []
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
                let isNowFavorite = state.breedsList.favoriteIDs.contains(id)
                state.favoriteIDs = state.breedsList.favoriteIDs

                if isNowFavorite {
                    guard let breed = state.breedsList.breeds.first(where: { $0.id == id }) else {
                        return .none
                    }
                    state.favorites.breeds.append(breed)
                    return .run { [breed] _ in
                        do {
                            try await favoritesPersistenceClient.saveFavorite(breed)
                        } catch {
                            // UI updated optimistically.
                        }
                    }
                } else {
                    state.favorites.breeds.removeAll(where: { $0.id == id })
                    return .run { _ in
                        do {
                            try await favoritesPersistenceClient.removeFavorite(id)
                        } catch {
                            // UI updated optimistically.
                        }
                    }
                }

            case .breedsList(.breedsResponse):
                state.breedsList.favoriteIDs = state.favoriteIDs
                return .none

            case .breedsList:
                return .none

            case let .favorites(.favoriteButtonTapped(id)):
                state.favoriteIDs.remove(id)
                state.breedsList.favoriteIDs = state.favoriteIDs
                return .run { _ in
                    do {
                        try await favoritesPersistenceClient.removeFavorite(id)
                    } catch {
                        // UI updated optimistically.
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
                state.favoriteIDs = Set(favorites.map(\.id))
                state.breedsList.favoriteIDs = state.favoriteIDs
                return .none

            case .favoritesLoaded(.failure):
                return .none
            }
        }
    }
}
