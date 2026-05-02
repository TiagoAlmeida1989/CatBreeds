import CatBreedsCore
import SwiftUI

struct FavoritesListContentView: View {
    let breeds: [Breed]
    let averageLifespan: String?
    let onBreedTap: (Breed) -> Void
    let onFavoriteTap: (Breed.ID) -> Void

    var body: some View {
        List {
            if let averageLifespan {
                Section {
                    Text("Average lifespan: \(averageLifespan)")
                        .accessibilityIdentifier(AccessibilityIdentifiers.Favourites.averageLifespan)
                }
            }

            ForEach(breeds) { breed in
                BreedRowButton(
                    breed: breed,
                    isFavorite: true,
                    onTap: { onBreedTap(breed) },
                    onFavoriteTap: { onFavoriteTap(breed.id) }
                )
            }
        }
    }
}
