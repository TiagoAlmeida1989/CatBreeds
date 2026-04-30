import Foundation

struct BreedsPage: Sendable {
    let breeds: [Breed]
    let hasNextPage: Bool

    init(breeds: [Breed], hasNextPage: Bool) {
        self.breeds = breeds
        self.hasNextPage = hasNextPage
    }
}

extension BreedsPage: Equatable {
    nonisolated static func == (lhs: BreedsPage, rhs: BreedsPage) -> Bool {
        lhs.breeds == rhs.breeds && lhs.hasNextPage == rhs.hasNextPage
    }
}
