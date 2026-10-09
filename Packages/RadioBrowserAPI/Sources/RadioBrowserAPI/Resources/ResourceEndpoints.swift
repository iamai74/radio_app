import Foundation

/// The country, language, tag and codec endpoints of the service.
///
/// All four resources share one shape — a plain list of a counted resource, optionally
/// filtered by a path segment — so they share one generic endpoint instead of four copies
/// that differ only in their element type. The named endpoints are type aliases over it.
///
/// The endpoint names its payload and routes and delegates everything else — request
/// building, mirror failover, decoding — to the shared ``RequestExecutor``. Its public
/// surface is ``ResourceFiltering`` (or ``ResourceEndpointProtocol`` where the service
/// offers no filtered route, as for codecs).
internal struct ResourceEndpoint<Resource: Sendable, Payload: Decodable>: ResourceFiltering {
    private let executor: RequestExecutor
    private let listEndpoint: APIEndpoint
    private let filterEndpoint: (@Sendable (String) -> APIEndpoint)?
    private let adapt: @Sendable (Payload) -> Resource

    init(
        executor: RequestExecutor,
        listEndpoint: APIEndpoint,
        filterEndpoint: (@Sendable (String) -> APIEndpoint)? = nil,
        adapt: @escaping @Sendable (Payload) -> Resource
    ) {
        self.executor = executor
        self.listEndpoint = listEndpoint
        self.filterEndpoint = filterEndpoint
        self.adapt = adapt
    }

    func getResources() async throws -> [Resource] {
        try await executor.fetch(Payload.self, endpoint: listEndpoint).map(adapt)
    }

    func getResources(withFilter filter: String) async throws -> [Resource] {
        guard let filterEndpoint else {
            preconditionFailure("This resource has no filtered route")
        }

        return try await executor.fetch(Payload.self, endpoint: filterEndpoint(filter)).map(adapt)
    }
}

internal typealias CountriesEndpoint = ResourceEndpoint<any Country, CountryObject>
internal typealias LanguagesEndpoint = ResourceEndpoint<any Language, CountedObject>
internal typealias TagsEndpoint = ResourceEndpoint<any StationTag, CountedObject>
internal typealias CodecsEndpoint = ResourceEndpoint<any Codec, CountedObject>

internal extension ResourceEndpoint where Resource == any Country, Payload == CountryObject {
    init(executor: RequestExecutor) {
        self.init(
            executor: executor,
            listEndpoint: APIEndpoint.countries,
            filterEndpoint: { APIEndpoint.countriesByFilter(filter: $0) },
            adapt: { $0 }
        )
    }

    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default
    ) {
        self.init(executor: RequestExecutor(networkClient: networkClient, configuration: configuration))
    }
}

internal extension ResourceEndpoint where Resource == any Language, Payload == CountedObject {
    init(executor: RequestExecutor) {
        self.init(
            executor: executor,
            listEndpoint: APIEndpoint.languages,
            filterEndpoint: { APIEndpoint.languagesByFilter(filter: $0) },
            adapt: { $0 }
        )
    }

    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default
    ) {
        self.init(executor: RequestExecutor(networkClient: networkClient, configuration: configuration))
    }
}

internal extension ResourceEndpoint where Resource == any StationTag, Payload == CountedObject {
    init(executor: RequestExecutor) {
        self.init(
            executor: executor,
            listEndpoint: APIEndpoint.tags,
            filterEndpoint: { APIEndpoint.tagsByFilter(filter: $0) },
            adapt: { $0 }
        )
    }

    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default
    ) {
        self.init(executor: RequestExecutor(networkClient: networkClient, configuration: configuration))
    }
}

internal extension ResourceEndpoint where Resource == any Codec, Payload == CountedObject {
    init(executor: RequestExecutor) {
        self.init(
            executor: executor,
            listEndpoint: APIEndpoint.codecs,
            adapt: { $0 }
        )
    }

    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default
    ) {
        self.init(executor: RequestExecutor(networkClient: networkClient, configuration: configuration))
    }
}
