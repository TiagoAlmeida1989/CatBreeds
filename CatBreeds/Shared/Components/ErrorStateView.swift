import SwiftUI

struct ErrorStateView: View {
    let title: String
    let message: String
    let retryAction: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
    }
}
