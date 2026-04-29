import Foundation

struct Breed: Identifiable, Equatable, Sendable {
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
