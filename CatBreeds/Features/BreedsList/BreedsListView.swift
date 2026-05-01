import SwiftUI
import ComposableArchitecture

struct BreedsListView: View {
    @Bindable var store: StoreOf<BreedsListFeature>

    var body: some View {
        List {
            switch store.viewState {
            case .loading:
                loadingState

            case let .error(message):
                errorState(message)

            case .emptySearch:
                emptySearchState

            case .empty:
                emptyState

            case .content:
                contentRows
            }
        }
        .listStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: store.paginationFooterState)
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
            breedDetailDestination(for: breedID)
        }
        .task {
            await store.send(.task).finish()
        }
    }
    
    
    @ViewBuilder
    private var contentRows: some View {
        ForEach(store.filteredBreeds) { breed in
            breedRow(breed)
        }
        
        paginationFooter
    }

    private func breedRow(_ breed: Breed) -> some View {
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

    @ViewBuilder
    private var paginationFooter: some View {
        if store.paginationFooterState != .hidden {
            PaginationFooterView(
                state: store.paginationFooterState,
                retryAction: {
                    store.send(.retryNextPageTapped)
                }
            )
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }

    private var loadingState: some View {
        ProgressView()
            .frame(maxWidth: .infinity, minHeight: 280)
            .listRowSeparator(.hidden)
    }

    private func errorState(_ message: String) -> some View {
        ErrorStateView(
            title: "Unable to load breeds",
            message: message,
            retryAction: {
                store.send(.retryTapped)
            }
        )
        .listRowSeparator(.hidden)
    }

    private var emptySearchState: some View {
        EmptyStateView(
            title: "No results",
            message: "Try searching for another breed name.",
            systemImage: "magnifyingglass"
        )
        .listRowSeparator(.hidden)
    }

    private var emptyState: some View {
        EmptyStateView(
            title: "No breeds available",
            message: "Pull to refresh and try loading breeds again.",
            systemImage: "cat"
        )
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    private func breedDetailDestination(for breedID: Breed.ID) -> some View {
        if let breed = store.breeds.first(where: { $0.id == breedID }) {
            BreedDetailView(
                breed: breed,
                onFavoriteTap: {
                    store.send(.favoriteButtonTapped(breed.id))
                }
            )
        }
    }
}
