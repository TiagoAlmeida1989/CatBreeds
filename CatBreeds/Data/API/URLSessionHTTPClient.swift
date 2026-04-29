import Foundation

struct URLSessionHTTPClient: HTTPClient {
    func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed
        }

        return (data, httpResponse)
    }
}
