import Foundation

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
