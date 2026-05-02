import CatBreedsCore
import Foundation

protocol FavoritesLocalDataSource {
    func fetchFavorites() async throws -> [Breed]
    func saveFavorite(_ breed: Breed) async throws
    func removeFavorite(id: Breed.ID) async throws
}
