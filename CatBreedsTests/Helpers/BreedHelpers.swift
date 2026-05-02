import CatBreedsCore
import Foundation
@testable import CatBreeds

extension Breed {
    static let abyssinian = makeBreed(
        id: "abys",
        name: "Abyssinian",
        origin: "Egypt",
        temperament: "Active, Energetic, Independent",
        description: "A social and intelligent breed.",
        lifeSpan: Lifespan(min: 14, max: 15)
    )

    static let bengal = makeBreed(
        id: "beng",
        name: "Bengal",
        origin: "United States",
        temperament: "Alert, Agile, Energetic",
        description: "A playful and curious breed.",
        lifeSpan: Lifespan(min: 12, max: 15)
    )

    static let maineCoon = makeBreed(
        id: "mcoo",
        name: "Maine Coon",
        origin: "United States",
        temperament: "Adaptable, Intelligent, Gentle",
        description: "A large and gentle breed.",
        lifeSpan: Lifespan(min: 12, max: 15)
    )

    static let unknownLifespan = makeBreed(
        id: "unknown",
        name: "Unknown Lifespan Breed",
        origin: "Unknown",
        temperament: "Unknown",
        description: "A breed without lifespan information.",
        lifeSpan: Lifespan(min: nil, max: nil),
        imageURL: nil
    )

    static func makeBreed(
        id: String,
        name: String,
        origin: String = "Unknown",
        temperament: String = "Unknown",
        description: String = "A test breed.",
        lifeSpan: Lifespan = Lifespan(min: 12, max: 15),
        imageURL: URL? = URL(string: "https://example.com/cat.jpg")
    ) -> Breed {
        Breed(
            id: id,
            name: name,
            origin: origin,
            temperament: temperament,
            description: description,
            lifeSpan: lifeSpan,
            image: imageURL.map {
                BreedImage(
                    id: "\(id)-image",
                    url: $0,
                    width: 640,
                    height: 480
                )
            }
        )
    }
}

func makeBreedsPage(
    breeds: [Breed],
    hasNextPage: Bool
) -> BreedsPage {
    BreedsPage(
        breeds: breeds,
        hasNextPage: hasNextPage
    )
}
