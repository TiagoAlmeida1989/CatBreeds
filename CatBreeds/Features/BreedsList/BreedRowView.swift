import CatBreedsCore
import SwiftUI
import NukeUI
import Nuke

struct BreedRowView: View {
    let breed: Breed
    let isFavorite: Bool
    let onFavoriteTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            LazyImage(url: breed.image?.url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.gray)
                        }
                }
            }
            .priority(.high)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(breed.name)
                    .font(.headline)

                Text(breed.origin)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onFavoriteTap) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityIdentifiers.BreedRow.favouriteButton(breed.id))
        }
        .padding(.vertical, 8)
    }
}
