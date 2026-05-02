import CatBreedsCore
import SwiftUI

struct BreedDetailView: View {
    let breed: Breed
    let onFavoriteTap: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BreedDetailImageView(imageURL: breed.image?.url)

                VStack(alignment: .leading, spacing: 16) {
                    Text(breed.name)
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)

                    InfoChipView(
                        systemImage: "mappin.and.ellipse",
                        text: breed.origin
                    )
                    .accessibilityIdentifier(AccessibilityIdentifiers.BreedDetail.originChip)

                    BreedDetailInfoSection(
                        title: "Temperament",
                        value: breed.temperament
                    )

                    BreedDetailInfoSection(
                        title: "Description",
                        value: breed.description
                    )

                    BreedDetailInfoSection(
                        title: "Lifespan",
                        value: breed.lifeSpan.displayValue
                    )
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
            }
        }
        .navigationTitle(breed.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onFavoriteTap) {
                    Image(systemName: breed.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(breed.isFavorite ? .yellow : .primary)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.BreedDetail.favouriteButton)
            }
        }
    }
}
