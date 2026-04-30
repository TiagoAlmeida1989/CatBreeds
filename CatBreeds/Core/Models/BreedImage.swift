import Foundation

struct BreedImage: Hashable, Sendable {
    let id: String?
    let url: URL?
    let width: Int?
    let height: Int?

    init(
        id: String?,
        url: URL?,
        width: Int? = nil,
        height: Int? = nil
    ) {
        self.id = id
        self.url = url
        self.width = width
        self.height = height
    }
}

extension BreedImage: Equatable {
    nonisolated static func == (lhs: BreedImage, rhs: BreedImage) -> Bool {
        lhs.id == rhs.id &&
        lhs.url == rhs.url &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }
}
