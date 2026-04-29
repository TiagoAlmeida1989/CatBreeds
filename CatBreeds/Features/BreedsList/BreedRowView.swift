import SwiftUI

struct BreedRowView: View {
    let breed: Breed
    let onFavoriteTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            
            // Image
            AsyncImage(url: breed.image?.url) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Texts
            VStack(alignment: .leading, spacing: 4) {
                Text(breed.name)
                    .font(.headline)

                Text(breed.origin)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // ⭐ FAVORITE BUTTON
            Button(action: onFavoriteTap) {
                Image(systemName: breed.isFavorite ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(breed.isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}
