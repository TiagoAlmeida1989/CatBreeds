import CatBreedsCore
import SwiftUI

struct BreedRowButton: View {
    let breed: Breed
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavoriteTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                BreedRowView(
                    breed: breed,
                    isFavorite: isFavorite,
                    onFavoriteTap: onFavoriteTap
                )
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
