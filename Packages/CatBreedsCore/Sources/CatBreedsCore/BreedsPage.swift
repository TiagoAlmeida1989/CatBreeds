public struct BreedsPage: Sendable {
    public let breeds: [Breed]
    public let hasNextPage: Bool

    public init(breeds: [Breed], hasNextPage: Bool) {
        self.breeds = breeds
        self.hasNextPage = hasNextPage
    }
}

extension BreedsPage: Equatable {
    nonisolated public static func == (lhs: BreedsPage, rhs: BreedsPage) -> Bool {
        lhs.breeds == rhs.breeds && lhs.hasNextPage == rhs.hasNextPage
    }
}
