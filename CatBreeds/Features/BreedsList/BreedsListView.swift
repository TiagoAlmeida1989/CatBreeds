import SwiftUI
import ComposableArchitecture

struct BreedsListView: View {
    let store: StoreOf<BreedsListFeature>

    var body: some View {
        // TODO: Migrate views to @ObservableState once TCA macro issue is resolved.
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.filteredBreeds) { breed in
                    NavigationLink(value: breed.id) {
                        BreedRowView(
                            breed: breed,
                            onFavoriteTap: {
                                viewStore.send(.favoriteButtonTapped(breed.id))
                            }
                        )
                    }
                    .onAppear {
                        viewStore.send(.loadNextPageIfNeeded(breed))
                    }
                }

                if viewStore.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }

                if let errorMessage = viewStore.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationDestination(for: Breed.ID.self) { breedID in
                if let breed = viewStore.breeds.first(where: { $0.id == breedID }) {
                    BreedDetailView(
                        breed: breed,
                        onFavoriteTap: {
                            viewStore.send(.favoriteButtonTapped(breed.id))
                        }
                    )
                }
            }
            .navigationTitle("Cat Breeds")
            .searchable(
                text: viewStore.binding(
                    get: \.searchText,
                    send: BreedsListFeature.Action.searchTextChanged
                )
            )
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}
