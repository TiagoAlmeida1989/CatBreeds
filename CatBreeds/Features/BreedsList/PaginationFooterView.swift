import SwiftUI

struct PaginationFooterView: View {

    enum ViewState: Equatable {
        case loading
        case failed(String)
        case hidden
    }

    let state: ViewState
    let retryAction: () -> Void

    var body: some View {
        switch state {
        case .loading:
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

        case .hidden:
            EmptyView()
        }
    }
}
