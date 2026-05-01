import Foundation

struct DefaultRequestBuilder: RequestBuilding {
    private let configuration: APIConfiguration

    init(configuration: APIConfiguration) {
        self.configuration = configuration
    }

    func buildRequest(from endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(
            url: configuration.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )

        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue(configuration.apiKey, forHTTPHeaderField: "x-api-key")

        return request
    }
}
