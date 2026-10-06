import Foundation

/// The country, language, tag and codec endpoints of the service.
///
/// The four used to be subclasses of one base class that differed only in their payload
/// type. They are values now: each names its payload and its routes and delegates
/// everything else — request building, mirror failover, decoding — to the shared
/// ``RequestExecutor``. Their public surface is the generic ``ResourceEndpointProtocol``
/// (and ``ResourceFiltering`` where the service offers a filtered route), so a consumer
/// that works for one resource works for all of them.
internal struct CountriesEndpoint: ResourceFiltering {
    typealias Resource = any Country

    private let executor: RequestExecutor

    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default,
        jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()
    ) {
        self.executor = RequestExecutor(
            networkClient: networkClient,
            configuration: configuration,
            jsonDecoder: jsonDecoder
        )
    }

    init(executor: RequestExecutor) {
        self.executor = executor
    }

    func getResources() async throws -> [any Country] {
        try await executor.fetch(CountryObject.self, endpoint: APIEndpoint.countries)
    }

    func getResources(withFilter filter: String) async throws -> [any Country] {
        try await executor.fetch(CountryObject.self, endpoint: APIEndpoint.countriesByFilter(filter: filter))
    }
}

internal struct LanguagesEndpoint: ResourceFiltering {
    typealias Resource = any Language

    private let executor: RequestExecutor

    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default,
        jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()
    ) {
        self.executor = RequestExecutor(
            networkClient: networkClient,
            configuration: configuration,
            jsonDecoder: jsonDecoder
        )
    }

    init(executor: RequestExecutor) {
        self.executor = executor
    }

    func getResources() async throws -> [any Language] {
        try await executor.fetch(LanguageObject.self, endpoint: APIEndpoint.languages)
    }

    func getResources(withFilter filter: String) async throws -> [any Language] {
        try await executor.fetch(LanguageObject.self, endpoint: APIEndpoint.languagesByFilter(filter: filter))
    }
}

internal struct TagsEndpoint: ResourceFiltering {
    typealias Resource = any Tag

    private let executor: RequestExecutor

    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default,
        jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()
    ) {
        self.executor = RequestExecutor(
            networkClient: networkClient,
            configuration: configuration,
            jsonDecoder: jsonDecoder
        )
    }

    init(executor: RequestExecutor) {
        self.executor = executor
    }

    func getResources() async throws -> [any Tag] {
        try await executor.fetch(TagObject.self, endpoint: APIEndpoint.tags)
    }

    func getResources(withFilter filter: String) async throws -> [any Tag] {
        try await executor.fetch(TagObject.self, endpoint: APIEndpoint.tagsByFilter(filter: filter))
    }
}

internal struct CodecsEndpoint: ResourceEndpointProtocol {
    typealias Resource = any Codec

    private let executor: RequestExecutor

    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default,
        jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()
    ) {
        self.executor = RequestExecutor(
            networkClient: networkClient,
            configuration: configuration,
            jsonDecoder: jsonDecoder
        )
    }

    init(executor: RequestExecutor) {
        self.executor = executor
    }

    func getResources() async throws -> [any Codec] {
        try await executor.fetch(CodecObject.self, endpoint: APIEndpoint.codecs)
    }
}
