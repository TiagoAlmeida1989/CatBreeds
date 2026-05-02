import CatBreedsCore
import SwiftUI

struct FavoritesListContentView: View {
    let breeds: [Breed]
    let averageLifespan: String?
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
                NavigationLink(value: breed) {
                    BreedRowView(
                        breed: breed,
                        isFavorite: true,
                        onFavoriteTap: {
                            onFavoriteTap(breed.id)
                        }
                    )
                }
            }
        }
    }
}
