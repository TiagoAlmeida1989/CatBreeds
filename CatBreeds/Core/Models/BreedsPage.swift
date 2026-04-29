import Foundation

struct BreedsPage: Equatable, Sendable {
    let breeds: [Breed]
    let hasNextPage: Bool

    init(breeds: [Breed], hasNextPage: Bool) {
        self.breeds = breeds
        self.hasNextPage = hasNextPage
    }
}
