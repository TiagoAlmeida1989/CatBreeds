import Foundation

struct CatBreedImageDTO: Decodable, Sendable {
    let id: String?
    let width: Int?
    let height: Int?
    let url: URL?
}
