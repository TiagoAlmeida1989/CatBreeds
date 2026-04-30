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
        
        enum LoadingState: Equatable {
            case idle
            case loadingInitial
            case loadingNextPage
            case refreshing
            case failed(String)
        }
        
        var breeds: [Breed] = []
        var searchText = ""
        var currentPage = 0
        var hasNextPage = true
        var loadingState: LoadingState = .idle

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
            switch loadingState {
            case .loadingInitial where breeds.isEmpty:
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
        
        var isLoading: Bool {
            switch loadingState {
            case .loadingInitial, .loadingNextPage, .refreshing:
                return true
            case .idle, .failed:
                return false
            }
        }
    }

    enum Action: Equatable {
        case task
        case breedsResponse(Result<BreedsPage, APIError>)
        case searchTextChanged(String)
        case loadNextPageIfNeeded(Breed)
        case favoriteButtonTapped(Breed.ID)
        case retryButtonTapped
        case refreshPulled
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

            state.loadingState = .loadingInitial

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
            switch state.loadingState {
            case .loadingInitial, .refreshing:
                state.breeds = page.breeds
                state.currentPage = page.hasNextPage ? 1 : 0
                
            case .loadingNextPage:
                let existingIDs = Set(state.breeds.map(\.id))
                state.breeds.append(contentsOf: page.breeds.filter { !existingIDs.contains($0.id) })
                
                if page.hasNextPage {
                    state.currentPage += 1
                }
                
            default:
                break
            }
            
            state.hasNextPage = page.hasNextPage
            state.loadingState = .idle
            return .none

        case .breedsResponse(.failure):
            if state.breeds.isEmpty {
                state.loadingState = .failed("Could not load cat breeds. Please try again.")
            } else {
                state.loadingState = .idle
            }
            
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

            state.loadingState = .loadingNextPage

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
            state.currentPage = 0
            state.hasNextPage = true
            state.loadingState = .loadingInitial

            let limit = state.pageSize

            return .run { send in
                do {
                    let page = try await breedsClient.fetchBreeds(0, limit)
                    await send(.breedsResponse(.success(page)))
                } catch {
                    await send(.breedsResponse(.failure(.requestFailed)))
                }
            }

        case .refreshPulled:
            state.currentPage = 0
            state.hasNextPage = true
            state.loadingState = .refreshing

            let limit = state.pageSize

            return .run { send in
                do {
                    let page = try await breedsClient.fetchBreeds(0, limit)
                    await send(.breedsResponse(.success(page)))
                } catch {
                    await send(.breedsResponse(.failure(.requestFailed)))
                }
            }

        }
    }
}
