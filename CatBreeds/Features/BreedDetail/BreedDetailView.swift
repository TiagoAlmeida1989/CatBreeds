import SwiftUI

struct BreedDetailView: View {
    let breed: Breed
    let onFavoriteTap: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AsyncImage(url: breed.image?.url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .clipped()

                VStack(alignment: .leading, spacing: 16) {
                    Text(breed.name)
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)

                    Label(breed.origin, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temperament")
                            .font(.headline)

                        Text(breed.temperament)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)

                        Text(breed.description)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lifespan")
                            .font(.headline)

                        Text(breed.lifeSpan.displayValue)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
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
            }
        }
    }
}
