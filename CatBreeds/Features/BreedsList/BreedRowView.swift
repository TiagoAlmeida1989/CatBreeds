import SwiftUI

struct BreedRowView: View {
    let breed: Breed

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: breed.image?.url) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)

                case .empty:
                    ProgressView()

                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(breed.name)
                    .font(.headline)

                Text(breed.origin)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: breed.isFavorite ? "star.fill" : "star")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
