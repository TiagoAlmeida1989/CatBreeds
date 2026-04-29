import Foundation

protocol RequestBuilding {
    func buildRequest(from endpoint: Endpoint) throws -> URLRequest
}
