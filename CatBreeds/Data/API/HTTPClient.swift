import Foundation

protocol HTTPClient {
    func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
