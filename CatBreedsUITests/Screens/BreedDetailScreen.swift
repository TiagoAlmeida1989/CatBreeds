import XCTest

struct BreedDetailScreen {
    let app: XCUIApplication

    // MARK: - Assertions

    @discardableResult
    func assertBreedNameVisible(_ name: String) -> Self {
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 1))
        return self
    }

    @discardableResult
    func assertOriginVisible() -> Self {
        let chip = app.descendants(matching: .any).matching(identifier: AccessibilityIdentifiers.BreedDetail.originChip).firstMatch
        XCTAssertTrue(chip.waitForExistence(timeout: 1))
        return self
    }

    @discardableResult
    func assertTemperamentVisible() -> Self {
        XCTAssertTrue(app.staticTexts["Temperament"].waitForExistence(timeout: 1))
        return self
    }

    @discardableResult
    func assertDescriptionVisible() -> Self {
        XCTAssertTrue(app.staticTexts["Description"].waitForExistence(timeout: 1))
        return self
    }

    @discardableResult
    func assertFavouriteButtonVisible() -> Self {
        XCTAssertTrue(app.buttons[AccessibilityIdentifiers.BreedDetail.favouriteButton].waitForExistence(timeout: 1))
        return self
    }

    // MARK: - Actions

    @discardableResult
    func tapFavouriteButton() -> Self {
        let button = app.buttons[AccessibilityIdentifiers.BreedDetail.favouriteButton]
        XCTAssertTrue(button.waitForExistence(timeout: 2))
        button.tap()
        return self
    }

    func goBack() -> BreedsListScreen {
        app.navigationBars.buttons.firstMatch.tap()
        return BreedsListScreen(app: app)
    }
}
