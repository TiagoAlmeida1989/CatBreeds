import ComposableArchitecture
import Foundation

struct BreedsListFeature: Reducer {
    struct State: Equatable {
        var breeds: [Breed] = []
        var searchText = ""
        var isLoading = false
        var errorMessage: String?
        var currentPage = 0
        var hasNextPage = true

        var filteredBreeds: [Breed] {
            guard !searchText.isEmpty else { return breeds }
            return breeds.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    enum Action: Equatable {
        case task
        case breedsResponse(Result<BreedsPage, APIError>)
        case searchTextChanged(String)
        case loadNextPageIfNeeded(Breed)
    }

    @Dependency(\.breedsClient) var breedsClient

    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case .task:
            guard state.breeds.isEmpty else { return .none }
            state.isLoading = true
            state.errorMessage = nil

            return .run { send in
                do {
                    let page = try await breedsClient.fetchBreeds(0, 10)
                    await send(.breedsResponse(.success(page)))
                } catch {
                    await send(.breedsResponse(.failure(.requestFailed)))
                }
            }

        case let .breedsResponse(.success(page)):
            state.isLoading = false
            state.breeds.append(contentsOf: page.breeds)
            state.hasNextPage = page.hasNextPage
            state.currentPage += 1
            return .none

        case .breedsResponse(.failure):
            state.isLoading = false
            state.errorMessage = "Could not load cat breeds. Please try again."
            return .none

        case let .searchTextChanged(searchText):
            state.searchText = searchText
            return .none

        case let .loadNextPageIfNeeded(breed):
            guard
                state.hasNextPage,
                !state.isLoading,
                state.breeds.last?.id == breed.id
            else {
                return .none
            }

            state.isLoading = true
            let nextPage = state.currentPage

            return .run { send in
                do {
                    let page = try await breedsClient.fetchBreeds(nextPage, 10)
                    await send(.breedsResponse(.success(page)))
                } catch {
                    await send(.breedsResponse(.failure(.requestFailed)))
                }
            }
        }
    }
}
