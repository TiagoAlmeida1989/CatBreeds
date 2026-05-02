import Foundation

public struct Breed: Identifiable, Hashable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let origin: String
    public let temperament: String
    public let description: String
    public let lifeSpan: Lifespan
    public let image: BreedImage?

    public init(
        id: String,
        name: String,
        origin: String,
        temperament: String,
        description: String,
        lifeSpan: Lifespan,
        image: BreedImage?
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.description = description
        self.lifeSpan = lifeSpan
        self.image = image
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
