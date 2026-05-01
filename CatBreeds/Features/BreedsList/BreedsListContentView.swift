import CatBreedsCore
import SwiftUI

struct BreedsListContentView: View {
    let breeds: [Breed]
    let paginationFooterState: PaginationFooterState
    let onBreedAppear: (Breed) -> Void
    let onFavoriteTap: (Breed.ID) -> Void
    let onRetryNextPageTap: () -> Void

    var body: some View {
        ForEach(breeds) { breed in
            NavigationLink(value: breed.id) {
                BreedRowView(
                    breed: breed,
                    onFavoriteTap: {
                        onFavoriteTap(breed.id)
                    }
                )
            }
            .onAppear {
                onBreedAppear(breed)
            }
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
