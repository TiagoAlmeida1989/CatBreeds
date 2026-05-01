import CatBreedsCore
import Foundation

enum CatBreedsEndpoint {
    static func breeds(page: Int, limit: Int) -> Endpoint {
        Endpoint(
            path: "breeds",
            method: .get,
            queryItems: [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        )
    }
}
