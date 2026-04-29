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
                    BreedRowView(
                        breed: breed,
                        onFavoriteTap: {}
                    )
                }
            }
            .navigationTitle("Favorites")
        }
    }
}
