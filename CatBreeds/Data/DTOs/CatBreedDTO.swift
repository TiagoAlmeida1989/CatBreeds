import Foundation

struct CatBreedDTO: Decodable, Sendable {
    let weight: CatWeightDTO?
    let id: String
    let name: String
    let temperament: String?
    let origin: String?
    let description: String?
    let lifeSpan: String?
    let referenceImageID: String?
    let image: CatBreedImageDTO?

    enum CodingKeys: String, CodingKey {
        case weight
        case id
        case name
        case temperament
        case origin
        case description
        case lifeSpan = "life_span"
        case referenceImageID = "reference_image_id"
        case image
    }
}
