import Foundation

/// The country, language, tag and codec endpoints of the service.
///
/// Each endpoint is a value that names its payload and its routes and delegates everything
/// else — request building, mirror failover, decoding — to the shared ``RequestExecutor``.
/// Their public surface is the generic ``ResourceEndpointProtocol`` (and
/// ``ResourceFiltering`` where the service offers a filtered route), so a consumer that
/// works for one resource works for all of them.
///
/// Languages, tags and codecs share one payload, ``CountedObject``; countries add an ISO
/// code and decode through ``CountryObject``.
internal struct CountriesEndpoint: ResourceFiltering, EndpointInitializing {
    typealias Resource = any Country

    private let executor: RequestExecutor

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

internal struct LanguagesEndpoint: ResourceFiltering, EndpointInitializing {
    typealias Resource = any Language

    private let executor: RequestExecutor

    init(executor: RequestExecutor) {
        self.executor = executor
    }

    func getResources() async throws -> [any Language] {
        try await executor.fetch(CountedObject.self, endpoint: APIEndpoint.languages)
    }

    func getResources(withFilter filter: String) async throws -> [any Language] {
        try await executor.fetch(CountedObject.self, endpoint: APIEndpoint.languagesByFilter(filter: filter))
    }
}

internal struct TagsEndpoint: ResourceFiltering, EndpointInitializing {
    typealias Resource = any StationTag

    private let executor: RequestExecutor

    init(executor: RequestExecutor) {
        self.executor = executor
    }

    func getResources() async throws -> [any StationTag] {
        try await executor.fetch(CountedObject.self, endpoint: APIEndpoint.tags)
    }

    func getResources(withFilter filter: String) async throws -> [any StationTag] {
        try await executor.fetch(CountedObject.self, endpoint: APIEndpoint.tagsByFilter(filter: filter))
    }
}

internal struct CodecsEndpoint: ResourceEndpointProtocol, EndpointInitializing {
    typealias Resource = any Codec

    private let executor: RequestExecutor

    init(executor: RequestExecutor) {
        self.executor = executor
    }

    func getResources() async throws -> [any Codec] {
        try await executor.fetch(CountedObject.self, endpoint: APIEndpoint.codecs)
    }
}
