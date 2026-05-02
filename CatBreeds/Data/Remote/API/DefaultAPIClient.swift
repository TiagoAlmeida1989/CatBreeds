import Foundation

struct DefaultAPIClient: APIClient {
    let httpClient: HTTPClient
    let requestBuilder: RequestBuilding

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try requestBuilder.buildRequest(from: endpoint)
        let (data, response) = try await httpClient.execute(request)

        guard (200...299).contains(response.statusCode) else {
            throw APIError.unexpectedStatusCode(response.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
