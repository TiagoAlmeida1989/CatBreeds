import SwiftUI

private struct SpinnerIcon: View {
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(Color.secondary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            .frame(width: 16, height: 16)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

struct PaginationFooterView: View {
    let state: PaginationFooterState
    let retryAction: () -> Void

    var body: some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(uiColor: .systemBackground))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .hidden:
            EmptyView()

        case .loading:
            HStack(spacing: 8) {
                SpinnerIcon()
                Text("Loading more...")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

        case let .failed(message):
            HStack(spacing: 12) {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button(action: retryAction) {
                    Image(systemName: "arrow.clockwise")
                        .font(.body.bold())
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}
