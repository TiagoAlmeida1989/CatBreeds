import SwiftUI

struct BreedDetailInfoSection: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}
