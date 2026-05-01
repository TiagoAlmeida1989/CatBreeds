import CatBreedsCore
import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    let store: StoreOf<FavoritesFeature>

    var body: some View {
        Group {
            switch store.viewState {
            case .empty:
                EmptyStateView(
                    title: "No favorites yet",
                    message: "Start adding breeds to your favorites.",
                    systemImage: "cat"
                )
            case .content:
                FavoritesListContentView(
                    breeds: store.breeds,
                    averageLifespan: store.averageLifespan,
                    onFavoriteTap: { id in
                        store.send(.favoriteButtonTapped(id))
                    }
                )
                
            }
        }
        .navigationTitle("Favorites")
        .navigationDestination(for: Breed.self) { selectedBreed in
            let breed = store.breeds.first {
                $0.id == selectedBreed.id
            } ?? {
                var removedBreed = selectedBreed
                removedBreed.isFavorite = false
                return removedBreed
            }()

            BreedDetailView(
                breed: breed,
                onFavoriteTap: {
                    store.send(.favoriteButtonTapped(breed.id))
                }
            )
        }
    }
}
