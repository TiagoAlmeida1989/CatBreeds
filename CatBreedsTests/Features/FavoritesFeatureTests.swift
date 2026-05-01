import CatBreedsCore
import ComposableArchitecture
import XCTest
@testable import CatBreeds

@MainActor
final class FavoritesFeatureTests: XCTestCase {

    // MARK: - Initial State

    func testInitialStateIsEmpty() {
        let state = FavoritesFeature.State()

        XCTAssertEqual(state.breeds, [])
        XCTAssertNil(state.averageLifespan)
    }

    // MARK: - Removing Favorites

    func testFavoriteButtonTappedRemovesBreed() async {
        let store = makeStore(
            breeds: [.abyssinian, .bengal]
        )

        await store.send(.favoriteButtonTapped(Breed.abyssinian.id)) {
            $0.breeds = [.bengal]
        }
    }

    func testFavoriteButtonTappedWithUnknownIDDoesNothing() async {
        let store = makeStore(
            breeds: [.abyssinian, .bengal]
        )

        await store.send(.favoriteButtonTapped("unknown-id"))
    }

    func testFavoriteButtonTappedRemovesOnlyMatchingBreed() async {
        let store = makeStore(
            breeds: [.abyssinian, .bengal, .maineCoon]
        )

        await store.send(.favoriteButtonTapped(Breed.bengal.id)) {
            $0.breeds = [.abyssinian, .maineCoon]
        }
    }

    // MARK: - Average Lifespan

    func testAverageLifespanReturnsNilWhenThereAreNoBreeds() {
        let state = FavoritesFeature.State()

        XCTAssertNil(state.averageLifespan)
    }

    func testAverageLifespanUsesAvailableBreedAverages() {
        let state = FavoritesFeature.State(
            breeds: [.abyssinian, .bengal]
        )

        XCTAssertEqual(state.averageLifespan, 14.0)
    }

    func testAverageLifespanIgnoresUnknownLifespans() {
        let state = FavoritesFeature.State(
            breeds: [.abyssinian, .unknownLifespan]
        )

        XCTAssertEqual(state.averageLifespan, 14.5)
    }

    func testAverageLifespanReturnsNilWhenAllLifespansAreUnknown() {
        let state = FavoritesFeature.State(
            breeds: [.unknownLifespan]
        )

        XCTAssertNil(state.averageLifespan)
    }
}

private extension FavoritesFeatureTests {
    func makeStore(
        breeds: [Breed] = []
    ) -> TestStore<FavoritesFeature.State, FavoritesFeature.Action> {
        TestStore(
            initialState: FavoritesFeature.State(breeds: breeds)
        ) {
            FavoritesFeature()
        }
    }
}

