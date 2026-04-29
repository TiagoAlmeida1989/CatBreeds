import Foundation

struct Lifespan: Equatable, Sendable {
    let min: Int?
    let max: Int?

    init(min: Int?, max: Int?) {
        self.min = min
        self.max = max
    }

    var average: Double? {
        switch (min, max) {
        case let (.some(min), .some(max)):
            return Double(min + max) / 2
        case let (.some(min), nil):
            return Double(min)
        case let (nil, .some(max)):
            return Double(max)
        case (nil, nil):
            return nil
        }
    }

    var displayValue: String {
        switch (min, max) {
        case let (.some(min), .some(max)):
            return "\(min) - \(max) years"
        case let (.some(min), nil):
            return "\(min)+ years"
        case let (nil, .some(max)):
            return "Up to \(max) years"
        case (nil, nil):
            return "Unknown"
        }
    }
}
