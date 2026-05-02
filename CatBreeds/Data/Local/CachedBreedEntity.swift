import CatBreedsCore
import Foundation
import SwiftData

@Model
final class CachedBreedEntity {
    @Attribute(.unique) var id: String
    var page: Int
    var position: Int
    var name: String
    var origin: String
    var temperament: String
    var breedDescription: String
    var minLifespan: Int?
    var maxLifespan: Int?
    var imageID: String?
    var imageURLString: String?
    var imageWidth: Int?
    var imageHeight: Int?

    init(breed: Breed, page: Int, position: Int) {
        self.id = breed.id
        self.page = page
        self.position = position
        self.name = breed.name
        self.origin = breed.origin
        self.temperament = breed.temperament
        self.breedDescription = breed.description
        self.minLifespan = breed.lifeSpan.min
        self.maxLifespan = breed.lifeSpan.max
        self.imageID = breed.image?.id
        self.imageURLString = breed.image?.url?.absoluteString
        self.imageWidth = breed.image?.width
        self.imageHeight = breed.image?.height
    }

    var domainModel: Breed {
        Breed(
            id: id,
            name: name,
            origin: origin,
            temperament: temperament,
            description: breedDescription,
            lifeSpan: Lifespan(min: minLifespan, max: maxLifespan),
            image: BreedImage(
                id: imageID,
                url: imageURLString.flatMap(URL.init(string:)),
                width: imageWidth,
                height: imageHeight
            )
        )
    }
}
