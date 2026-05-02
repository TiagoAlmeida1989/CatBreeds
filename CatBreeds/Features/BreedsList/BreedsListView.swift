import CatBreedsCore
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
        .navigationDestination(
            item: $store.scope(state: \.detail, action: \.detail)
        ) { detailStore in
            BreedDetailView(store: detailStore)
        }
        .task {
            await store.send(.task).finish()
        }
    }

    private var contentRows: some View {
        BreedsListContentView(
            breeds: store.filteredBreeds,
            favoriteIDs: store.favoriteIDs,
            paginationFooterState: store.paginationFooterState,
            onBreedTap: { breed in
                store.send(.breedTapped(breed))
            },
            onBreedAppear: { breed in
                store.send(.loadNextPageIfNeeded(breed))
            },
            onFavoriteTap: { breedID in
                store.send(.favoriteButtonTapped(breedID))
            },
            onRetryNextPageTap: {
                store.send(.retryNextPageTapped)
            }
        )
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
}
