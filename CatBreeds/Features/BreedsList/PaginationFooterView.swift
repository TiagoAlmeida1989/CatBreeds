import SwiftUI

struct PaginationFooterView: View {
    let loadState: BreedsListFeature.LoadState
    let retryAction: () -> Void

    var body: some View {
        switch loadState {
        case .loadingNextPage:
            ProgressView()
                .frame(maxWidth: .infinity)

        case let .failed(message):
            VStack(spacing: 8) {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Retry", action: retryAction)
                    .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)

        case .idle, .loading, .refreshing:
            EmptyView()
        }
    }
}
