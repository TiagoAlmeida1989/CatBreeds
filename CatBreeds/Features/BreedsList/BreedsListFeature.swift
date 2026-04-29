import ComposableArchitecture
import Foundation

struct BreedsListFeature: Reducer {
    struct State: Equatable {
        enum ViewState: Equatable {
            case loading
            case error(String)
            case emptySearch
            case empty
            case content
        }
        
        var breeds: [Breed] = []
        var searchText = ""
        var isLoading = false
        var errorMessage: String?
        var currentPage = 0
        var hasNextPage = true

        let pageSize = 10

        var isSearching: Bool {
            !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var filteredBreeds: [Breed] {
            guard isSearching else { return breeds }

            return breeds.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        var viewState: ViewState {
            if isLoading && breeds.isEmpty {
                return .loading
            }

            if let errorMessage, breeds.isEmpty {
                return .error(errorMessage)
            }

            if filteredBreeds.isEmpty && isSearching {
                return .emptySearch
            }

            if filteredBreeds.isEmpty {
                return .empty
            }

            return .content
        }
    }

    enum Action: Equatable {
        case task
        case breedsResponse(Result<BreedsPage, APIError>)
        case searchTextChanged(String)
        case loadNextPageIfNeeded(Breed)
        case favoriteButtonTapped(Breed.ID)
        case retryButtonTapped
    }

    @Dependency(\.breedsClient) var breedsClient

    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case .task:
            guard state.breeds.isEmpty, !state.isLoading else {
                return .none
            }

            state.isLoading = true
            state.errorMessage = nil

            let page = state.currentPage
            let limit = state.pageSize

            return .run { send in
                do {
                    let page = try await breedsClient.fetchBreeds(page, limit)
                    await send(.breedsResponse(.success(page)))
                } catch {
                    await send(.breedsResponse(.failure(.requestFailed)))
                }
            }
        case let .breedsResponse(.success(page)):
            state.isLoading = false
            state.errorMessage = nil
            
            let existingIDs = Set(state.breeds.map(\.id))
            let newBreeds = page.breeds.filter { !existingIDs.contains($0.id) }

            state.breeds.append(contentsOf: newBreeds)
            state.hasNextPage = page.hasNextPage && !newBreeds.isEmpty

            if page.hasNextPage {
                state.currentPage += 1
            }

            return .none

        case .breedsResponse(.failure):
            state.isLoading = false
            state.errorMessage = "Could not load cat breeds. Please try again."
            return .none
        
        case let .favoriteButtonTapped(id):
            guard let index = state.breeds.firstIndex(where: { $0.id == id }) else {
                return .none
            }

            state.breeds[index].isFavorite.toggle()
            return .none

        case let .searchTextChanged(searchText):
            state.searchText = searchText
            return .none

        case let .loadNextPageIfNeeded(breed):
            guard
                !state.isSearching,
                state.hasNextPage,
                !state.isLoading,
                state.breeds.last?.id == breed.id
            else {
                return .none
            }

            state.isLoading = true
            state.errorMessage = nil

            let page = state.currentPage
            let limit = state.pageSize

            return .run { send in
                do {
                    let page = try await breedsClient.fetchBreeds(page, limit)
                    await send(.breedsResponse(.success(page)))
                } catch {
                    await send(.breedsResponse(.failure(.requestFailed)))
                }
            }
            
        case .retryButtonTapped:
            state.breeds = []
            state.currentPage = 0
            state.hasNextPage = true
            state.errorMessage = nil
            state.isLoading = true

            let page = state.currentPage
            let limit = state.pageSize

            return .run { send in
                do {
                    try await Task.sleep(nanoseconds: 700_000_000)
                    let page = try await breedsClient.fetchBreeds(page, limit)
                    await send(.breedsResponse(.success(page)))
                } catch {
                    await send(.breedsResponse(.failure(.requestFailed)))
                }
            }

        }
    }
}
