import Foundation

struct URLSessionHTTPClient: HTTPClient {
    func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown(.unknown)
            }
            return (data, httpResponse)
        } catch let urlError as URLError {
            throw APIError(urlError)
        }
    }
}
