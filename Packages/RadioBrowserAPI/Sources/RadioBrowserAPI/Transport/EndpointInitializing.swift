import Foundation

/// The initialisers every endpoint of a client shares.
///
/// An endpoint is built either with the pipeline of a whole client — what the composition
/// root uses so every endpoint of a client shares one executor — or with its own
/// dependencies, which is how the package's tests drive a single endpoint. The second
/// shape is written once here instead of once per endpoint.
internal protocol EndpointInitializing {
    /// Designated: the request pipeline this endpoint runs its routes through.
    init(executor: RequestExecutor)
}

internal extension EndpointInitializing {
    /// An endpoint with its own transport, mirrors and decoder.
    ///
    /// Every call builds a fresh ``RequestExecutor``; a client built through the
    /// composition root shares one instead, through ``init(executor:)``.
    init(
        networkClient: NetworkClientProtocol,
        configuration: RadioBrowserConfiguration = .default,
        jsonDecoder: JSONDecoderProtocol = DefaultJSONDecoder()
    ) {
        self.init(
            executor: RequestExecutor(
                networkClient: networkClient,
                configuration: configuration,
                jsonDecoder: jsonDecoder
            )
        )
    }
}
