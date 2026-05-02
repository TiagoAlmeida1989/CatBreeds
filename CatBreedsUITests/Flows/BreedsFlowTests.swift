import XCTest

final class BreedsFlowTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Breeds List

    func test_breedsListScreen_showsBreedsAfterLaunch() {
        BreedsListScreen(app: app)
            .assertBreedsListVisible()
            .assertBreedVisible("Abyssinian")
            .assertBreedVisible("Bengal")
            .assertBreedVisible("Birman")
            .assertBreedVisible("Ragdoll")
    }

    // MARK: - Breed Detail

    func test_tappingBreed_opensDetailScreenWithAllRequiredFields() {
        BreedsListScreen(app: app)
            .assertBreedsListVisible()
            .tapBreed("Abyssinian")
            .assertBreedNameVisible("Abyssinian")
            .assertOriginVisible()
            .assertTemperamentVisible()
            .assertDescriptionVisible()
            .assertFavouriteButtonVisible()
    }

    // MARK: - Favourites Flow

    func test_userFavouritesBreed_andSeesItInFavouritesWithAverageLifespan() {
        BreedsListScreen(app: app)
            .assertBreedsListVisible()
            .tapFavouriteButton(forBreedID: "abys")
            .goToFavourites()
            .assertFavouritesScreenVisible()
            .assertBreedVisible("Abyssinian")
            .assertAverageLifespanVisible()
    }

    func test_userUnfavouritesBreed_fromFavouritesScreen_breedDisappears() {
        BreedsListScreen(app: app)
            .assertBreedsListVisible()
            .tapFavouriteButton(forBreedID: "abys")
            .goToFavourites()
            .assertFavouritesScreenVisible()
            .assertBreedVisible("Abyssinian")
            .tapFavouriteButton(forBreedID: "abys")
            .assertBreedNotVisible("Abyssinian")
            .assertEmptyStateVisible()
    }

    func test_userFavouritesBreedFromDetailScreen_breedAppearsInFavourites() {
        BreedsListScreen(app: app)
            .assertBreedsListVisible()
            .tapBreed("Ragdoll")
            .assertBreedNameVisible("Ragdoll")
            .tapFavouriteButton()
            .goBack()
            .goToFavourites()
            .assertFavouritesScreenVisible()
            .assertBreedVisible("Ragdoll")
            .assertAverageLifespanVisible()
    }
}
