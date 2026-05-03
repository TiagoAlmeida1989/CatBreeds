import CatBreedsCore
import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    @Bindable var store: StoreOf<FavoritesFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
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
        } destination: { store in
            switch store.case {
            case .detail(let detailStore):
                BreedDetailView(store: detailStore)
            }
        }
    }
}
