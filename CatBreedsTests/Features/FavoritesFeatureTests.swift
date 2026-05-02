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

    // MARK: - Favorite intent

    func testFavoriteButtonTappedProducesNoLocalMutation() async {
        let store = makeStore(breeds: [.abyssinian, .bengal])

        // FavoritesFeature emits intent only; AppFeature owns removal from breeds.
        await store.send(.favoriteButtonTapped(Breed.abyssinian.id))
        await store.send(.favoriteButtonTapped(Breed.bengal.id))
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

        XCTAssertEqual(state.averageLifespan, "14 years")
    }

    func testAverageLifespanIgnoresUnknownLifespans() {
        let state = FavoritesFeature.State(
            breeds: [.abyssinian, .unknownLifespan]
        )

        XCTAssertEqual(state.averageLifespan, "14,5 years")
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

