import CatBreedsCore
import SwiftUI
import ComposableArchitecture

struct BreedDetailView: View {
    let store: StoreOf<BreedDetailFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BreedDetailImageView(imageURL: store.breed.image?.url)

                VStack(alignment: .leading, spacing: 16) {
                    Text(store.breed.name)
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)

                    InfoChipView(
                        systemImage: "mappin.and.ellipse",
                        text: store.breed.origin
                    )
                    .accessibilityIdentifier(AccessibilityIdentifiers.BreedDetail.originChip)

                    BreedDetailInfoSection(
                        title: "Temperament",
                        value: store.breed.temperament
                    )

                    BreedDetailInfoSection(
                        title: "Description",
                        value: store.breed.description
                    )

                    BreedDetailInfoSection(
                        title: "Lifespan",
                        value: store.breed.lifeSpan.displayValue
                    )
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
            }
        }
        .navigationTitle(store.breed.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.favoriteButtonTapped)
                } label: {
                    Image(systemName: store.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(store.isFavorite ? .yellow : .primary)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.BreedDetail.favouriteButton)
            }
        }
    }
}
