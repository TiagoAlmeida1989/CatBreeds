import Foundation

struct Breed: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let origin: String
    let temperament: String
    let description: String
    let lifeSpan: Lifespan
    let image: BreedImage?
    var isFavorite: Bool

    init(
        id: String,
        name: String,
        origin: String,
        temperament: String,
        description: String,
        lifeSpan: Lifespan,
        image: BreedImage?,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.description = description
        self.lifeSpan = lifeSpan
        self.image = image
        self.isFavorite = isFavorite
    }
}

extension Breed: Equatable {
    nonisolated static func == (lhs: Breed, rhs: Breed) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.origin == rhs.origin &&
        lhs.temperament == rhs.temperament &&
        lhs.description == rhs.description &&
        lhs.lifeSpan == rhs.lifeSpan &&
        lhs.image == rhs.image &&
        lhs.isFavorite == rhs.isFavorite
    }
}

// MARK: - Statistics

extension Array where Element == Breed {
    var averageLifespan: Double? {
        let values = compactMap(\.lifeSpan.average)
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }
}
