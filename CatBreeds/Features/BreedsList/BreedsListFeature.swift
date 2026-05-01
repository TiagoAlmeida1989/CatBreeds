import Foundation
import ComposableArchitecture

// MARK: - Supporting Types

enum BreedsListLoadState: Equatable {
    case idle
    case loading
    case loadingNextPage
    case refreshing
    case failed(String)
}

enum BreedsListViewState: Equatable {
    case loading
    case error(String)
    case emptySearch
    case empty
    case content
}

enum BreedsListLoadType: Equatable {
    case initial
    case refresh
    case nextPage
}

enum PaginationFooterState: Equatable {
    case hidden
    case loading
    case failed(String)
}

// MARK: - Feature

@Reducer
struct BreedsListFeature {

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        var breeds: [Breed] = []
        var searchText = ""

        var nextPage = 0
        var canLoadMore = true

        var loadState: BreedsListLoadState = .idle
        var paginationFooterState: PaginationFooterState = .hidden

        var isSearching: Bool {
            !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var filteredBreeds: [Breed] {
            guard isSearching else { return breeds }

            return breeds.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        var viewState: BreedsListViewState {
            switch loadState {
            case .loading:
                return .loading

            case .refreshing where breeds.isEmpty:
                return .loading

            case let .failed(message) where breeds.isEmpty:
                return .error(message)

            default:
                if filteredBreeds.isEmpty && isSearching {
                    return .emptySearch
                }

                if breeds.isEmpty {
                    return .empty
                }

                return .content
            }
        }

        var paginationFooterStateID: String {
            switch paginationFooterState {
            case .hidden:
                return "hidden"
            case .loading:
                return "loading"
            case let .failed(message):
                return "failed-\(message)"
            }
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case task
        case retryTapped
        case refreshPulled
        case loadNextPageIfNeeded(Breed)
        case retryNextPageTapped

        case searchTextChanged(String)
        case favoriteButtonTapped(Breed.ID)

        case breedsResponse(Result<BreedsPage, APIError>, BreedsListLoadType)
    }

    // MARK: - Dependencies

    @Dependency(\.breedsClient) var breedsClient

    // MARK: - Body

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            // MARK: - Initial Load

            case .task:
                guard state.breeds.isEmpty else {
                    return .none
                }

                state.loadState = .loading
                return load(page: 0, type: .initial)

            // MARK: - Retry Initial

            case .retryTapped:
                state.loadState = .loading
                return load(page: 0, type: .initial)

            // MARK: - Pull to Refresh

            case .refreshPulled:
                state.loadState = .refreshing
                return load(page: 0, type: .refresh)

            // MARK: - Pagination

            case let .loadNextPageIfNeeded(breed):
                guard
                    !state.isSearching,
                    state.canLoadMore,
                    state.loadState == .idle,
                    state.breeds.last?.id == breed.id
                else {
                    return .none
                }

                state.loadState = .loadingNextPage
                state.paginationFooterState = .loading
                return load(page: state.nextPage, type: .nextPage)

            case .retryNextPageTapped:
                print("[PAGINATION] 🔁 retryNextPageTapped — isSearching: \(state.isSearching), canLoadMore: \(state.canLoadMore), loadState: \(state.loadState)")
                guard
                    !state.isSearching,
                    state.canLoadMore
                else {
                    print("[PAGINATION] 🚫 retryNextPageTapped guard failed")
                    return .none
                }

                state.loadState = .loadingNextPage
                state.paginationFooterState = .loading
                print("[PAGINATION] ✅ paginationFooterState → .loading")
                return load(page: state.nextPage, type: .nextPage)

            // MARK: - Search

            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            // MARK: - Favorite

            case let .favoriteButtonTapped(id):
                guard let index = state.breeds.firstIndex(where: { $0.id == id }) else {
                    return .none
                }

                state.breeds[index].isFavorite.toggle()
                return .none

            // MARK: - Response Success

            case let .breedsResponse(.success(page), loadType):
                switch loadType {
                case .initial, .refresh:
                    state.breeds = page.breeds
                    state.nextPage = page.hasNextPage ? 1 : 0

                case .nextPage:
                    let existingIDs = Set(state.breeds.map(\.id))
                    let newBreeds = page.breeds.filter {
                        !existingIDs.contains($0.id)
                    }

                    state.breeds.append(contentsOf: newBreeds)

                    if page.hasNextPage {
                        state.nextPage += 1
                    }
                }

                state.canLoadMore = page.hasNextPage
                state.loadState = .idle
                state.paginationFooterState = .hidden
                print("[PAGINATION] ✅ breedsResponse success (.\(loadType)) — paginationFooterState → .hidden")

                return .none

            // MARK: - Response Failure

            case let .breedsResponse(.failure, loadType):
                switch loadType {
                case .initial, .refresh:
                    state.loadState = .failed("Could not load cat breeds.")

                case .nextPage:
                    state.loadState = .idle
                    state.paginationFooterState = .failed("Could not load more breeds.")
                    print("[PAGINATION] ❌ breedsResponse failure (.nextPage) — paginationFooterState → .failed")
                }

                return .none
            }
        }
    }

    // MARK: - Private

    private func load(
        page: Int,
        type: BreedsListLoadType
    ) -> Effect<Action> {
        .run { send in
            do {
                if type == .nextPage {
                    try? await Task.sleep(for: .milliseconds(500))
                }

                let result = try await breedsClient.fetchBreeds(page, 10)
                await send(.breedsResponse(.success(result), type))
            } catch {
                await send(.breedsResponse(.failure(.requestFailed), type))
            }
        }
    }
}
