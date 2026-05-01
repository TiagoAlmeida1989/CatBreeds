import CatBreedsCore
import Foundation

protocol BreedsLocalDataSource {
    func saveBreeds(_ breeds: [Breed], page: Int) async throws
    func fetchBreeds(page: Int) async throws -> [Breed]
    func deleteAllBreeds() async throws
}
