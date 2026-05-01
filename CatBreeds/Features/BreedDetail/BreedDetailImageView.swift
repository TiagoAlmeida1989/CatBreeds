import CatBreedsCore
import SwiftUI
import NukeUI

struct BreedDetailImageView: View {
    let imageURL: URL?

    var body: some View {
        LazyImage(url: imageURL) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .frame(height: 240)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private var placeholder: some View {
        Color.gray.opacity(0.2)
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
            }
    }
}
