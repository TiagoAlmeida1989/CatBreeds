import SwiftUI
import ComposableArchitecture

struct BreedsListView: View {
    let store: StoreOf<BreedsListFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                switch viewStore.viewState {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case let .error(message):
                    ErrorStateView(
                        title: "Unable to load breeds",
                        message: message,
                        retryAction: {
                            viewStore.send(.retryButtonTapped)
                        }
                    )

                case .emptySearch:
                    EmptyStateView(
                        title: "No results",
                        message: "Try searching for another breed name.",
                        systemImage: "magnifyingglass"
                    )

                case .empty:
                    EmptyStateView(
                        title: "No breeds available",
                        message: "There are no cat breeds to display yet.",
                        systemImage: "cat"
                    )

                case .content:
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
                    }
                }
            }
            .navigationTitle("Cat Breeds")
            .searchable(
                text: viewStore.binding(
                    get: \.searchText,
                    send: BreedsListFeature.Action.searchTextChanged
                )
            )
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
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}
