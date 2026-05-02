import XCTest

struct FavouritesScreen {
    let app: XCUIApplication

    // MARK: - Assertions

    @discardableResult
    func assertFavouritesScreenVisible() -> Self {
        XCTAssertTrue(app.navigationBars["Favorites"].waitForExistence(timeout: 1))
        return self
    }

    @discardableResult
    func assertBreedVisible(_ name: String) -> Self {
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 1))
        return self
    }

    @discardableResult
    func assertBreedNotVisible(_ name: String) -> Self {
        XCTAssertFalse(app.staticTexts[name].exists)
        return self
    }

    @discardableResult
    func assertAverageLifespanVisible() -> Self {
        let label = app.staticTexts.matching(identifier: AccessibilityIdentifiers.Favourites.averageLifespan).firstMatch
        XCTAssertTrue(label.waitForExistence(timeout: 1))
        return self
    }

    @discardableResult
    func assertEmptyStateVisible() -> Self {
        XCTAssertTrue(app.staticTexts["No favorites yet"].waitForExistence(timeout: 1))
        return self
    }

    // MARK: - Actions

    @discardableResult
    func tapBreed(_ name: String) -> BreedDetailScreen {
        app.staticTexts[name].tap()
        return BreedDetailScreen(app: app)
    }

    @discardableResult
    func tapFavouriteButton(forBreedID breedID: String) -> Self {
        let buttons = app.buttons.matching(identifier: AccessibilityIdentifiers.BreedRow.favouriteButton(breedID))
        XCTAssertTrue(buttons.element(boundBy: 0).waitForExistence(timeout: 1))
        buttons.element(boundBy: 1).tap()
        return self
    }

    func goToBreedsList() -> BreedsListScreen {
        app.tabBars.buttons["Breeds"].tap()
        return BreedsListScreen(app: app)
    }
}
