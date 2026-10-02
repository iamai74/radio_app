import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed(Error)
    case networkFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        }
    }
}
