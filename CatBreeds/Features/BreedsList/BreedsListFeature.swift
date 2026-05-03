import CatBreedsCore
import Foundation
import ComposableArchitecture

// MARK: - Supporting Types

enum BreedsListLoadState: Equatable {
    case idle
    case loading
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

    @Reducer
    enum Path {
        case detail(BreedDetailFeature)
    }

    private enum Constants {
        static let pageSize = 10
    }

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        var breeds: [Breed] = []
        var favoriteIDs: Set<Breed.ID> = []
        var path = StackState<Path.State>()
        var searchText = ""

        var nextPage = 0
        var canLoadMore = true

        var loadState: BreedsListLoadState = .idle
        var paginationFooterState: PaginationFooterState = .hidden

        var isSearching: Bool {
            !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var canRequestNextPage: Bool {
            !isSearching && canLoadMore
        }

        var filteredBreeds: [Breed] {
            guard isSearching else { return breeds }

            return breeds.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        private var isEmpty: Bool {
            breeds.isEmpty
        }

        private var isFilteredEmpty: Bool {
            filteredBreeds.isEmpty
        }

        var viewState: BreedsListViewState {
            if case .loading = loadState {
                return .loading
            }

            if case .refreshing = loadState, isEmpty {
                return .loading
            }

            if case let .failed(message) = loadState, isEmpty {
                return .error(message)
            }

            if isSearching && isFilteredEmpty {
                return .emptySearch
            }

            if isEmpty {
                return .empty
            }

            return .content
        }

        func isLastBreed(_ breed: Breed) -> Bool {
            breeds.last?.id == breed.id
        }

        mutating func startNextPageLoading() {
            paginationFooterState = .loading
        }

        mutating func apply(
            _ page: BreedsPage,
            loadType: BreedsListLoadType
        ) {
            switch loadType {
            case .initial, .refresh:
                breeds = page.breeds
                nextPage = page.hasNextPage ? 1 : 0

            case .nextPage:
                let existingIDs = Set(breeds.map(\.id))
                let newBreeds = page.breeds.filter {
                    !existingIDs.contains($0.id)
                }

                breeds.append(contentsOf: newBreeds)

                if page.hasNextPage {
                    nextPage += 1
                }
            }

            canLoadMore = page.hasNextPage
            loadState = .idle
            paginationFooterState = .hidden
        }

        mutating func applyFailure(_ error: APIError, loadType: BreedsListLoadType) {
            switch loadType {
            case .initial, .refresh:
                loadState = .failed(error.userMessage)

            case .nextPage:
                loadState = .idle
                paginationFooterState = .failed(error.userMessage)
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

        case breedTapped(Breed)
        case searchTextChanged(String)
        case favoriteButtonTapped(Breed.ID)

        case breedsResponse(Result<BreedsPage, APIError>, BreedsListLoadType)
        case path(StackActionOf<Path>)
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
                    state.canRequestNextPage,
                    state.paginationFooterState != .loading,
                    state.isLastBreed(breed)
                else {
                    return .none
                }

                state.startNextPageLoading()
                return load(page: state.nextPage, type: .nextPage)

            case .retryNextPageTapped:
                guard
                    state.canRequestNextPage,
                    state.paginationFooterState != .loading
                else {
                    return .none
                }

                state.startNextPageLoading()
                return load(page: state.nextPage, type: .nextPage)

            // MARK: - Detail

            case let .breedTapped(breed):
                state.path.append(.detail(BreedDetailFeature.State(breed: breed, isFavorite: state.favoriteIDs.contains(breed.id))))
                return .none

            case let .path(.element(_, .detail(.delegate(.favoriteToggled(id))))):
                return .send(.favoriteButtonTapped(id))

            case .path:
                return .none

            // MARK: - Search

            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            // MARK: - Favorite

            case .favoriteButtonTapped:
                return .none

            // MARK: - Response Success

            case let .breedsResponse(.success(page), loadType):
                state.apply(page, loadType: loadType)
                return .none

            // MARK: - Response Failure

            case let .breedsResponse(.failure(error), loadType):
                state.applyFailure(error, loadType: loadType)
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    // MARK: - Private

    private func load(
        page: Int,
        type: BreedsListLoadType
    ) -> Effect<Action> {
        .run { send in
            do {
                let result = try await breedsClient.fetchBreeds(page, Constants.pageSize)
                await send(.breedsResponse(.success(result), type))
            } catch let error as APIError {
                await send(.breedsResponse(.failure(error), type))
            } catch {
                await send(.breedsResponse(.failure(.unknown(.unknown)), type))
            }
        }
    }
}

extension BreedsListFeature.Path.State: Equatable {}
extension BreedsListFeature.Path.Action: Equatable {}
