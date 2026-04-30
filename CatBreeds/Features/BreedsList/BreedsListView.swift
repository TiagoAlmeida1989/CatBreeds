import SwiftUI
import ComposableArchitecture

struct BreedsListView: View {
    let store: StoreOf<BreedsListFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                switch viewStore.viewState {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 280)
                        .listRowSeparator(.hidden)

                case let .error(message):
                    ErrorStateView(
                        title: "Unable to load breeds",
                        message: message,
                        retryAction: {
                            viewStore.send(.retryTapped)
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

                    PaginationFooterView(
                        state: viewStore.loadState.paginationViewState,
                        retryAction: {
                            viewStore.send(.retryNextPageTapped)
                        }
                    )
                    .listRowSeparator(.hidden)
                    
                }
            }
            .refreshable {
                await viewStore.send(.refreshPulled).finish()
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
