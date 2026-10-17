# Storage Package — AI Agent Instructions

Package-scoped rules for `Packages/Storage`. Project-wide rules live in the repository root `AGENTS.md`; read that first.

## Purpose

Owns persistence. Uses SwiftData and exposes storage-oriented abstractions.

It must not depend on UI, and the `RadioBrowserAPI` package must not depend on `Storage`.

## Structure (single `Storage` target)

- Storage entity protocols and record DTOs: `StationEntity`/`StationRecord`, plus country/tag/language/codec equivalents.
- SwiftData model implementations: `*EntityImpl`.
- Store protocols: `StationReading`/`StationWriting`, `FacetReading`/`FacetWriting`; concrete stores: `DataStore` (`@MainActor`), `BackgroundStore` (`@ModelActor`).
- Filtering/ordering: `StationFilter`, `StationOrderBy`, `FacetFilter`.

## Filtering parity

Station filtering has both persistence-level and in-memory behaviour:

- predicates that can be pushed into SQLite/SwiftData;
- operations that must run in memory (for example, tag filtering).

When changing filtering, preserve parity between the persistence query path, the in-memory path, post-processing, ordering, and pagination/windowing. Do not add a filter to only one path. Define the behaviour once and derive both implementations from the same semantic rule.

`FilterParityTests` is important regression protection for this.

## Performance

Large imports can involve tens of thousands of records. Avoid unnecessary work on the main actor: avoid intermediate copies and repeated conversions, and prefer the existing background storage behaviour where appropriate. Do not compromise correctness or actor isolation, and do not optimize based on assumptions — inspect the actual data flow first.

## Models vs persistence

API models and persistence models are intentionally separate (see the root `AGENTS.md`). Mapping happens in the application layer through adapters such as `init(from:)` on the record types. Do not make persistence entities depend directly on API package types merely to avoid writing mapping code.

## Rules

- Do not make `Storage` depend on UI.
- Do not put SwiftData persistence logic in `Radio/Middleware` when it belongs naturally here.
- In-memory containers are supported for tests and previews (`StorageContainer.create(isInMemory:)`); prefer them over temporary persistence.

## Testing

- Suite: `StorageTests` (Swift Testing).
- Run with `swift test` from `Packages/Storage`.
- Focus: filtering, ordering, pagination, persistence, failure propagation, async behaviour, in-memory vs persistent storage, and parity between query paths.
