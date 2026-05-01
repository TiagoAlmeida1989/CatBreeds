import SwiftUI

struct InfoChipView: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.gray.opacity(0.12))
        .clipShape(Capsule())
    }
}
