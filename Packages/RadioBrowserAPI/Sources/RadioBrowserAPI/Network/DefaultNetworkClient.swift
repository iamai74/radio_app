import Foundation

public final class DefaultNetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let userAgent: String

    public init(session: URLSession = .shared, userAgent: String = "RadioApp/1.0") {
        self.session = session
        self.userAgent = userAgent
    }

    public func fetch(request: URLRequest) async throws -> Data {
        var request = request
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}
