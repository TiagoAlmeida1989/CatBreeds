import Foundation

// Mirror of CatBreeds/Shared/AccessibilityIdentifiers.swift
// XCUITest runs out-of-process so it cannot import the app target directly.
enum AccessibilityIdentifiers {
    enum BreedRow {
        static func favouriteButton(_ breedID: String) -> String {
            "favouriteButton_\(breedID)"
        }
    }

    enum BreedDetail {
        static let originChip = "detail_originChip"
        static let favouriteButton = "detail_favouriteButton"
    }

    enum Favourites {
        static let averageLifespan = "favourites_averageLifespan"
    }
}
