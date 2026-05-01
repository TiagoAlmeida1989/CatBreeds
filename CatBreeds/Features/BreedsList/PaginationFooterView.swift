import SwiftUI

struct PaginationFooterView: View {
    let state: PaginationFooterState
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.leading, 16)

            content
                .frame(maxWidth: .infinity)
                .frame(minHeight: 56)
                .padding(.horizontal, 16)
                .background(.background)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .hidden:
            EmptyView()

        case .loading:
            HStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.regular)

                Text("Loading more...")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

        case let .failed(message):
            VStack(spacing: 8) {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Retry") {
                    retryAction()
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 8)
        }
    }
}
