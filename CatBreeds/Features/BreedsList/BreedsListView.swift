import SwiftUI
import ComposableArchitecture

struct BreedsListView: View {
    @Bindable var store: StoreOf<BreedsListFeature>

    var body: some View {
        List {
            switch store.viewState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 280)
                    .listRowSeparator(.hidden)

            case let .error(message):
                ErrorStateView(
                    title: "Unable to load breeds",
                    message: message,
                    retryAction: {
                        store.send(.retryTapped)
                    }
                )
                .listRowSeparator(.hidden)

            case .emptySearch:
                EmptyStateView(
                    title: "No results",
                    message: "Try searching for another breed name.",
                    systemImage: "magnifyingglass"
                )
                .listRowSeparator(.hidden)

            case .empty:
                EmptyStateView(
                    title: "No breeds available",
                    message: "Pull to refresh and try loading breeds again.",
                    systemImage: "cat"
                )
                .listRowSeparator(.hidden)

            case .content:
                ForEach(store.filteredBreeds) { breed in
                    NavigationLink(value: breed.id) {
                        BreedRowView(
                            breed: breed,
                            onFavoriteTap: {
                                store.send(.favoriteButtonTapped(breed.id))
                            }
                        )
                    }
                    .onAppear {
                        store.send(.loadNextPageIfNeeded(breed))
                    }
                }

                PaginationFooterView(
                    state: store.loadState.paginationViewState,
                    retryAction: {
                        store.send(.retryNextPageTapped)
                    }
                )
                .listRowSeparator(.hidden)
            }
        }
        .refreshable {
            await store.send(.refreshPulled).finish()
        }
        .navigationTitle("Cat Breeds")
        .searchable(
            text: Binding(
                get: { store.searchText },
                set: { store.send(.searchTextChanged($0)) }
            )
        )
        .navigationDestination(for: Breed.ID.self) { breedID in
            if let breed = store.breeds.first(where: { $0.id == breedID }) {
                BreedDetailView(
                    breed: breed,
                    onFavoriteTap: {
                        store.send(.favoriteButtonTapped(breed.id))
                    }
                )
            }
        }
        .task {
            await store.send(.task).finish()
        }
    }
}

// MARK: - Mapping

private extension BreedsListLoadState {
    var paginationViewState: PaginationFooterView.ViewState {
        switch self {
        case .loadingNextPage: .loading
        case let .failed(message): .failed(message)
        default: .hidden
        }
    }
}
