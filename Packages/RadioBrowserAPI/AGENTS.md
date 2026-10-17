# RadioBrowserAPI Package — AI Agent Instructions

Package-scoped rules for `Packages/RadioBrowserAPI`. Project-wide rules live in the repository root `AGENTS.md`; read that first.

## Purpose

Owns all communication with the Radio Browser service: models, decoding, routing, networking, endpoints, and API-related errors.

It must not depend on `Storage` or `UILibrary`.

## Structure

Separate areas for:

- decoding
- facade
- resources
- routes
- stations
- transport

## Key concepts

- Facade/configuration: `RadioBrowserAPI`, `RadioBrowserConfiguration`.
- Stations: `Station`, `StationQuery`, `StationPages` (AsyncSequence), `StationSortOrder`, `StationFetching`, `StationSearching`, `StationLookup`, `StationsEndpointProtocol`.
- Resources: `Country`, `Language`, `Codec`, `StationTag`, `ResourceEndpointProtocol`, `ResourceFiltering`.
- Endpoints/transport: `APIEndpoint`, `EndpointDefinition`, `URLBuilding`/`URLBuilder`, `NetworkClientProtocol`/`DefaultNetworkClient`, `EndpointExecuting`, failover transport.
- Errors: `APIError`.

## Concurrency

This package explicitly enables strict concurrency checking:

```swift
.enableExperimentalFeature("StrictConcurrency=complete")
```

Treat concurrency correctness as a first-class requirement and keep the target warning-free under strict checking.

## Rules

- Do not put application-specific persistence or UI logic into this package.
- Expose domain/API data, not SwiftData entities.
- If a new endpoint is required, follow the existing endpoint/route/transport abstractions instead of adding a one-off `URLSession` call in application code or elsewhere.
- Prefer the existing `NetworkClientProtocol` and failover abstractions over raw networking.

## Testing

- Suite: `RadioBrowserAPITests` (Swift Testing).
- Run with `swift test` from `Packages/RadioBrowserAPI`.
- Focus: decoding, endpoint construction, errors, network behaviour, and failover behaviour. JSON fixtures live under `Tests/RadioBrowserAPITests/Mocks/Data`.
- Opt-in live-network suite: `RADIO_BROWSER_LIVE_TESTS=1 swift test --filter LiveServiceTests`.
