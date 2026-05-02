import CatBreedsCore
import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    @Bindable var store: StoreOf<FavoritesFeature>

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
                    onBreedTap: { breed in
                        store.send(.breedTapped(breed))
                    },
                    onFavoriteTap: { id in
                        store.send(.favoriteButtonTapped(id))
                    }
                )
            }
        }
        .navigationTitle("Favorites")
        .navigationDestination(
            item: $store.scope(state: \.detail, action: \.detail)
        ) { detailStore in
            BreedDetailView(store: detailStore)
        }
    }
}
