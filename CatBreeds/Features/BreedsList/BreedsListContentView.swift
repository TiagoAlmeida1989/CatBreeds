import CatBreedsCore
import SwiftUI

struct BreedsListContentView: View {
    let breeds: [Breed]
    let favoriteIDs: Set<Breed.ID>
    let paginationFooterState: PaginationFooterState
    let onBreedTap: (Breed) -> Void
    let onBreedAppear: (Breed) -> Void
    let onFavoriteTap: (Breed.ID) -> Void
    let onRetryNextPageTap: () -> Void

    var body: some View {
        ForEach(breeds) { breed in
            BreedRowButton(
                breed: breed,
                isFavorite: favoriteIDs.contains(breed.id),
                onTap: { onBreedTap(breed) },
                onFavoriteTap: { onFavoriteTap(breed.id) }
            )
            .onAppear { onBreedAppear(breed) }
        }

        if paginationFooterState != .hidden {
            PaginationFooterView(
                state: paginationFooterState,
                retryAction: onRetryNextPageTap
            )
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }
}
