import Foundation

struct DefaultRequestBuilder: RequestBuilding {
    private let baseURL = URL(string: "https://api.thecatapi.com/v1")!
    private let apiKey = "live_rKVJF494Z91fqeASd9Fx7ZGk8kV863Mi5to68YuY8X78K605D4BK37QN1pafl0Xw"

    func buildRequest(from endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )

        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        return request
    }
}
