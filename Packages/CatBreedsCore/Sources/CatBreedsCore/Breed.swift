import Foundation

public struct Breed: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let origin: String
    public let temperament: String
    public let description: String
    public let lifeSpan: Lifespan
    public let image: BreedImage?
    public var isFavorite: Bool

    public init(
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
    nonisolated public static func == (lhs: Breed, rhs: Breed) -> Bool {
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

private let lifespanFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1
    formatter.numberStyle = .decimal
    return formatter
}()

extension Array where Element == Breed {
    public var averageLifespan: Double? {
        let values = compactMap(\.lifeSpan.average)
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    public var averageLifespanFormatted: String? {
        guard let average = averageLifespan else { return nil }
        let number = NSNumber(value: average)
        let formatted = lifespanFormatter.string(from: number) ?? "\(average)"
        return "\(formatted) years"
    }
}
