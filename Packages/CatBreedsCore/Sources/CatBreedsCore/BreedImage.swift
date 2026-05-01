import Foundation

public struct BreedImage: Hashable, Sendable {
    public let id: String?
    public let url: URL?
    public let width: Int?
    public let height: Int?

    public init(
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
    nonisolated public static func == (lhs: BreedImage, rhs: BreedImage) -> Bool {
        lhs.id == rhs.id &&
        lhs.url == rhs.url &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }
}
