import ComposableArchitecture
import XCTest
@testable import CatBreeds

@MainActor
final class BreedsListFeatureTests: XCTestCase {

    func testInitialLoadSuccess() async {
        let page0 = BreedsPage(
            breeds: [.abyssinian, .bengal],
            hasNextPage: true
        )

        let store = TestStore(
            initialState: BreedsListFeature.State()
        ) {
            BreedsListFeature()
        }

        store.dependencies.breedsClient.fetchBreeds = { page, limit in
            XCTAssertEqual(page, 0)
            XCTAssertEqual(limit, 10)
            return page0
        }

        await store.send(.task) {
            $0.loadState = .loading
        }

        await store.receive(.breedsResponse(.success(page0), .initial)) {
            $0.breeds = page0.breeds
            $0.nextPage = 1
            $0.canLoadMore = true
            $0.loadState = .idle
        }

        XCTAssertEqual(store.state.viewState, .content)
    }

    func testInitialLoadFailure() async {
        let store = TestStore(
            initialState: BreedsListFeature.State()
        ) {
            BreedsListFeature()
        }

        store.dependencies.breedsClient.fetchBreeds = { _, _ in
            throw APIError.requestFailed
        }

        await store.send(.task) {
            $0.loadState = .loading
        }

        await store.receive(.breedsResponse(.failure(.requestFailed), .initial)) {
            $0.loadState = .failed("Could not load cat breeds.")
        }

        XCTAssertEqual(store.state.viewState, .error("Could not load cat breeds."))
    }

    func testSearchFiltering() async {
        var state = BreedsListFeature.State()
        state.breeds = [.abyssinian, .bengal]

        let store = TestStore(
            initialState: state
        ) {
            BreedsListFeature()
        }

        await store.send(.searchTextChanged("Aby")) {
            $0.searchText = "Aby"
        }

        XCTAssertEqual(store.state.filteredBreeds, [.abyssinian])
        XCTAssertEqual(store.state.viewState, .content)

        await store.send(.searchTextChanged("No results")) {
            $0.searchText = "No results"
        }

        XCTAssertEqual(store.state.filteredBreeds, [])
        XCTAssertEqual(store.state.viewState, .emptySearch)
    }

    func testFavoriteToggle() async {
        var state = BreedsListFeature.State()
        state.breeds = [.abyssinian]

        let store = TestStore(
            initialState: state
        ) {
            BreedsListFeature()
        }

        await store.send(.favoriteButtonTapped(Breed.abyssinian.id)) {
            $0.breeds[0].isFavorite = true
        }

        await store.send(.favoriteButtonTapped(Breed.abyssinian.id)) {
            $0.breeds[0].isFavorite = false
        }
    }

    func testPaginationSuccess() async {
        var state = BreedsListFeature.State()
        state.breeds = [.abyssinian]
        state.nextPage = 1
        state.canLoadMore = true
        state.loadState = .idle

        let page1 = BreedsPage(
            breeds: [.bengal, .maineCoon],
            hasNextPage: true
        )

        let store = TestStore(
            initialState: state
        ) {
            BreedsListFeature()
        }

        store.dependencies.breedsClient.fetchBreeds = { page, limit in
            XCTAssertEqual(page, 1)
            XCTAssertEqual(limit, 10)
            return page1
        }

        await store.send(.loadNextPageIfNeeded(.abyssinian)) {
            $0.paginationFooterState = .loading
        }

        await store.receive(.breedsResponse(.success(page1), .nextPage)) {
            $0.breeds = [.abyssinian, .bengal, .maineCoon]
            $0.nextPage = 2
            $0.canLoadMore = true
            $0.loadState = .idle
            $0.paginationFooterState = .hidden
        }

        XCTAssertEqual(store.state.viewState, .content)
    }

    func testPaginationFailureKeepsContentViewState() async {
        var state = BreedsListFeature.State()
        state.breeds = [.abyssinian]
        state.nextPage = 1
        state.canLoadMore = true
        state.loadState = .idle

        let store = TestStore(
            initialState: state
        ) {
            BreedsListFeature()
        }

        store.dependencies.breedsClient.fetchBreeds = { _, _ in
            throw APIError.requestFailed
        }

        await store.send(.loadNextPageIfNeeded(.abyssinian)) {
            $0.paginationFooterState = .loading
        }

        await store.receive(.breedsResponse(.failure(.requestFailed), .nextPage)) {
            $0.loadState = .idle
            $0.paginationFooterState = .failed("Could not load more breeds.")
        }

        XCTAssertEqual(store.state.breeds, [.abyssinian])
        XCTAssertEqual(store.state.viewState, .content)
    }

    func testRetryNextPageSuccess() async {
        var state = BreedsListFeature.State()
        state.breeds = [.abyssinian]
        state.nextPage = 1
        state.canLoadMore = true
        state.loadState = .failed("Could not load more breeds.")

        let page1 = BreedsPage(
            breeds: [.bengal],
            hasNextPage: false
        )

        let store = TestStore(
            initialState: state
        ) {
            BreedsListFeature()
        }

        store.dependencies.breedsClient.fetchBreeds = { page, limit in
            XCTAssertEqual(page, 1)
            XCTAssertEqual(limit, 10)
            return page1
        }

        await store.send(.retryNextPageTapped) {
            $0.paginationFooterState = .loading
        }

        await store.receive(.breedsResponse(.success(page1), .nextPage)) {
            $0.breeds = [.abyssinian, .bengal]
            $0.canLoadMore = false
            $0.loadState = .idle
            $0.paginationFooterState = .hidden
        }

        XCTAssertEqual(store.state.nextPage, 1)
        XCTAssertEqual(store.state.viewState, .content)
    }

    func testPullToRefreshSuccess() async {
        var state = BreedsListFeature.State()
        state.breeds = [.abyssinian, .bengal]
        state.nextPage = 2
        state.canLoadMore = true
        state.loadState = .idle

        let refreshedPage = BreedsPage(
            breeds: [.maineCoon],
            hasNextPage: true
        )

        let store = TestStore(
            initialState: state
        ) {
            BreedsListFeature()
        }

        store.dependencies.breedsClient.fetchBreeds = { page, limit in
            XCTAssertEqual(page, 0)
            XCTAssertEqual(limit, 10)
            return refreshedPage
        }

        await store.send(.refreshPulled) {
            $0.loadState = .refreshing
        }

        await store.receive(.breedsResponse(.success(refreshedPage), .refresh)) {
            $0.breeds = [.maineCoon]
            $0.nextPage = 1
            $0.canLoadMore = true
            $0.loadState = .idle
        }

        XCTAssertEqual(store.state.viewState, .content)
    }
}
