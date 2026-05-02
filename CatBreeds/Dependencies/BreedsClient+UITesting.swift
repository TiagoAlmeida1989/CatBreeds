#if DEBUG
import CatBreedsCore
import Foundation

extension BreedsClient {
    static let uiTestingValue = BreedsClient(
        fetchBreeds: { page, _ in
            let fileName = "breeds_page_\(page)"
            guard
                let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
                let data = try? Data(contentsOf: url),
                let dtos = try? JSONDecoder().decode([CatBreedDTO].self, from: data)
            else {
                return BreedsPage(breeds: [], hasNextPage: false)
            }
            return BreedsPage(breeds: dtos.map { CatBreedMapper.map($0) }, hasNextPage: false)
        }
    )
}
#endif
