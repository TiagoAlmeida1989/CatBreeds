import CatBreedsCore
import Foundation

enum CatBreedMapper {
    static func map(_ dto: CatBreedDTO) -> Breed {
        Breed(
            id: dto.id,
            name: dto.name,
            origin: dto.origin ?? "Unknown",
            temperament: dto.temperament ?? "Unknown",
            description: dto.description ?? "No description available.",
            lifeSpan: LifespanParser.parse(dto.lifeSpan),
            image: dto.image.map {
                BreedImage(
                    id: $0.id ?? dto.referenceImageID,
                    url: $0.url,
                    width: $0.width,
                    height: $0.height
                )
            }
        )
    }
}

private enum LifespanParser {
    static func parse(_ value: String?) -> Lifespan {
        guard let value else {
            return Lifespan(min: nil, max: nil)
        }

        let numbers = value
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }

        return Lifespan(
            min: numbers.first,
            max: numbers.dropFirst().first ?? numbers.first
        )
    }
}
