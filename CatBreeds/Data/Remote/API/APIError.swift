import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case requestFailed
    case decodingFailed
    case unexpectedStatusCode(Int)
}
