import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case networkUnavailable
    case timeout
    case unexpectedStatusCode(Int)
    case decodingFailed
    case unknown(URLError.Code)
}

extension APIError {
    init(_ urlError: URLError) {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            self = .networkUnavailable
        case .timedOut, .cannotConnectToHost:
            self = .timeout
        default:
            self = .unknown(urlError.code)
        }
    }

    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .unknown:
            return true
        case .unexpectedStatusCode(let code):
            return code >= 500
        case .invalidURL, .decodingFailed:
            return false
        }
    }

    var userMessage: String {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Check your network and try again."
        case .timeout:
            return "The request timed out. Please try again."
        case .decodingFailed:
            return "Something went wrong. Please try again later."
        case .unexpectedStatusCode(let code) where code >= 500:
            return "Server error. Please try again later."
        case .invalidURL, .unexpectedStatusCode, .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
