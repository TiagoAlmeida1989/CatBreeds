import XCTest

struct BreedsListScreen {
    let app: XCUIApplication

    // MARK: - Assertions

    @discardableResult
    func assertBreedsListVisible() -> Self {
        XCTAssertTrue(app.navigationBars["Cat Breeds"].waitForExistence(timeout: 1))
        return self
    }

    @discardableResult
    func assertBreedVisible(_ name: String) -> Self {
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 1))
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
        // The NavigationLink cell inherits the child button's identifier, producing two matches.
        // element(boundBy: 1) selects the actual star button (child), not the cell wrapper (parent).
        let buttons = app.buttons.matching(identifier: AccessibilityIdentifiers.BreedRow.favouriteButton(breedID))
        XCTAssertTrue(buttons.element(boundBy: 0).waitForExistence(timeout: 1))
        buttons.element(boundBy: 1).tap()
        return self
    }

    func goToFavourites() -> FavouritesScreen {
        app.tabBars.buttons["Favorites"].tap()
        return FavouritesScreen(app: app)
    }
}
