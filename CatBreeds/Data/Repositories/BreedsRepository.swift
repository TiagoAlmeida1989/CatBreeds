import CatBreedsCore
import Foundation

protocol BreedsRepository {
    func fetchBreeds(page: Int, limit: Int) async throws -> BreedsPage
}
