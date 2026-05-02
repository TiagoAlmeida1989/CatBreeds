import CatBreedsCore
import Foundation

protocol CatBreedsRemoteDataSource {
    func fetchBreeds(page: Int, limit: Int) async throws -> BreedsPage
}

struct DefaultCatBreedsRemoteDataSource: CatBreedsRemoteDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchBreeds(page: Int, limit: Int) async throws -> BreedsPage {
        let endpoint = CatBreedsEndpoint.breeds(page: page, limit: limit)
        let dtos: [CatBreedDTO] = try await apiClient.request(endpoint)
        let breeds = dtos.map { CatBreedMapper.map($0) }
        return BreedsPage(breeds: breeds, hasNextPage: dtos.count == limit)
    }
}
