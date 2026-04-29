import Foundation

struct BreedImage: Equatable, Sendable {
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
