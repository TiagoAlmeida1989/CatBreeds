import SwiftUI

struct BreedsPaginationFooterView: View {
    let state: PaginationFooterState
    let retryAction: () -> Void

    var body: some View {
        PaginationFooterView(
            state: state,
            retryAction: retryAction
        )
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}
