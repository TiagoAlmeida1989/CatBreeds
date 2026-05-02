import Foundation

struct CatWeightDTO: Decodable, Sendable {
    let imperial: String?
    let metric: String?
}
