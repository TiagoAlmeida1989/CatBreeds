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

        do {
            let dtos: [CatBreedDTO] = try await apiClient.request(endpoint)
            let breeds = dtos.map { CatBreedMapper.map($0) }
            let hasNextPage = dtos.count == limit
            return BreedsPage(breeds: breeds, hasNextPage: hasNextPage)
        } catch {
            throw error
        }
    }
}
