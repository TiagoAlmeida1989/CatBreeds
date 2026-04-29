import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    let store: StoreOf<FavoritesFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                if let average = viewStore.averageLifespan {
                    Section {
                        Text("Average lifespan: \(average, specifier: "%.1f") years")
                            .font(.headline)
                    }
                }

                ForEach(viewStore.breeds) { breed in
                    NavigationLink(value: breed) {
                        BreedRowView(
                            breed: breed,
                            onFavoriteTap: {
                                viewStore.send(.favoriteButtonTapped(breed.id))
                            }
                        )
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationDestination(for: Breed.self) { selectedBreed in
                let breed = viewStore.breeds.first {
                    $0.id == selectedBreed.id
                } ?? {
                    var removedBreed = selectedBreed
                    removedBreed.isFavorite = false
                    return removedBreed
                }()

                BreedDetailView(
                    breed: breed,
                    onFavoriteTap: {
                        viewStore.send(.favoriteButtonTapped(breed.id))
                    }
                )
            }
        }
    }
}
