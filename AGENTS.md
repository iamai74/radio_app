# Radio App — AI Agent Instructions

## 1. Project Overview

Radio is a cross-platform Apple application for browsing and working with Internet radio stations.

The project currently targets:

- iOS 17+
- macOS 14+
- Swift 6.4

The repository is organized as an XcodeGen-generated application with multiple local Swift packages.

The project is intentionally structured around:

- Swift Package Manager modules
- protocol-oriented boundaries
- dependency injection
- SwiftData persistence
- asynchronous APIs
- Swift concurrency
- reusable SwiftUI components
- explicit separation between API, storage, application/middleware, and UI

Do not treat the current prototype state as permission to collapse these boundaries.

---

## 2. Source of Truth

Before making a non-trivial change:

1. Inspect the existing implementation.
2. Inspect the relevant Swift Package and its public interfaces.
3. Inspect `project.yml` if the change affects targets, dependencies, build settings, or generated Xcode configuration.
4. Check existing tests.
5. Preserve established module boundaries.

There is currently no single architecture document that overrides the source code. In case of ambiguity, prefer the existing module boundaries and public protocols over introducing a new architectural pattern.

If a significant architectural decision changes, document it in the appropriate project documentation rather than silently changing conventions.

---

## 3. Technology Stack

The project currently uses:

- Swift 6.4
- Swift Package Manager
- XcodeGen
- SwiftUI
- SwiftData
- Combine
- Needle / NeedleFoundation for dependency injection
- SwiftLint
- iOS 17+
- macOS 14+

Some package targets enable Swift concurrency checking explicitly.

Do not introduce another dependency-injection framework, networking framework, persistence framework, or UI framework without an explicit reason and approval.

Prefer the technologies already used by the affected module.

---

## 4. Repository Structure

The main application and package boundaries are:

```text
Radio/
├── iOS/
├── macOS/
└── Middleware/

Packages/
├── Architecture/
├── RadioBrowserAPI/
├── Storage/
├── UILibrary/
└── Resources/

project.yml
.swiftlint.yml
```

### Application

`Radio/` contains platform entry points and application-layer composition.

`Radio/Middleware/` contains application-level services and adapters connecting domain/package APIs.

### Packages

Each package owns a focused responsibility.

- `Architecture` — shared architectural protocols and lightweight abstractions.
- `RadioBrowserAPI` — Radio Browser API client, models, decoding, routing, networking, and API-related errors.
- `Storage` — persistence and storage abstractions built around SwiftData.
- `UILibrary` — reusable SwiftUI UI components and UI-facing models.
- `Resources` — shared application resources.

Do not bypass package boundaries simply because importing another module appears convenient.

---

## 5. XcodeGen

`project.yml` is the source of truth for generated Xcode project configuration.

Do not manually edit generated `.xcodeproj` files to make permanent project configuration changes.

When changing:

- targets
- source paths
- package dependencies
- build settings
- deployment targets
- build plugins
- schemes

update `project.yml` instead and regenerate the Xcode project.

Do not commit manual changes to generated Xcode configuration when they should be represented in `project.yml`.

---

## 6. Swift Style

Follow the repository's `.swiftlint.yml`.

Important project-level constraints include:

- SwiftLint is strict.
- Maximum line length is 160 for warnings and 200 for errors.
- Type names have configured length limits.
- Cyclomatic complexity has configured warning/error thresholds.
- Analyzer rules include unused imports.
- Trailing whitespace is intentionally disabled.
- The project uses several additional opt-in SwiftLint rules.

Do not disable a lint rule locally merely to make a change pass.

If an existing rule creates a genuine architectural or readability problem, consider changing the shared configuration deliberately rather than scattering suppressions through source files.

Prefer the existing project style over personal Swift style preferences.

---

## 7. Swift Concurrency

The project uses Swift 6.4 and concurrency-aware APIs.

Some packages explicitly enable:

```swift
.enableExperimentalFeature("StrictConcurrency=complete")
```

Treat concurrency correctness as a first-class requirement.

Prefer:

- structured concurrency;
- `async` / `await`;
- `Task`;
- actors and global actors where appropriate;
- explicit `Sendable` boundaries when required.

Avoid:

- unnecessary detached tasks;
- unstructured shared mutable state;
- unsafe synchronization;
- `@unchecked Sendable` as a shortcut;
- silencing concurrency diagnostics without understanding the ownership model.

When using `Task.detached`, there must be a concrete reason that the work needs detached execution and its captured values must satisfy the required isolation/sendability constraints.

Do not move work to another actor merely to silence a compiler warning.

---

## 8. Main Actor

UI-facing and application objects that interact with SwiftUI or UI state may be `@MainActor`.

Existing application services such as `AppComponent`, `AppInitializer`, and `StationsService` use main-actor isolation.

Preserve existing actor isolation when extending these types.

Do not remove `@MainActor` merely to make an API easier to call.

When moving expensive work away from the main actor, keep the public orchestration clear and return to the appropriate actor only when necessary.

---

## 9. Dependency Injection

The application uses Needle / NeedleFoundation for dependency injection.

The architecture package also contains lightweight dependency-resolution abstractions:

- `DependencyResolver`
- `DependencyProvider`
- `ModuleResolver`
- `ModuleFactory`
- `ModuleProtocol`
- `CoordinatorProtocol`
- `NavigatorProtocol`

Do not introduce a second dependency-injection mechanism for the same application layer.

Prefer constructor injection for ordinary dependencies.

Use the existing Needle composition root for application-level dependency graphs.

A service should not reach into global state to obtain dependencies that can be injected.

---

## 10. Architecture Package

`Packages/Architecture` defines shared architectural contracts.

Important concepts include:

- `ViewModelProtocol`
- `ViewProtocol`
- `NavigatorProtocol`
- `CoordinatorProtocol`
- `ModuleProtocol`
- `ModuleFactoryProtocol`
- `DependencyResolver`
- `DependencyProvider`

These are architectural boundaries, not a requirement to force every new type into a protocol.

Do not create protocols solely because "every class should have a protocol".

Create a protocol when:

- a boundary requires abstraction;
- dependency injection benefits from substitution;
- tests require a meaningful seam;
- multiple implementations are expected;
- the abstraction represents a stable contract.

Avoid speculative abstractions.

---

## 11. Application Layer

`Radio/Middleware` is the application composition layer between infrastructure packages and the UI/application entry points.

Current examples include:

- `AppInitializer`
- `AppComponent`
- `StationsService`
- `CountriesService`
- `LanguagesService`
- `TagsService`
- `CodecsService`
- adapters such as `StationAdapter`

Application services may coordinate multiple packages.

They should not become replacements for the underlying packages.

For example:

- API concerns belong in `RadioBrowserAPI`.
- persistence concerns belong in `Storage`.
- reusable UI belongs in `UILibrary`.
- application orchestration belongs in `Radio/Middleware`.

---

## 12. RadioBrowserAPI

`Packages/RadioBrowserAPI` owns communication with the Radio Browser service.

Its structure includes separate areas for:

- decoding
- facade
- resources
- routes
- stations
- transport

Important concepts include:

- API endpoint definitions
- URL/query construction
- network transport
- failover transport
- API errors
- station models and queries
- resource endpoints

Do not put application-specific persistence or UI logic into this package.

The API package should expose domain/API data, not SwiftData entities.

If a new API endpoint is required, follow the existing endpoint/route/transport abstractions instead of adding a one-off `URLSession` call in application code.

---

## 13. Storage

`Packages/Storage` owns persistence.

It uses SwiftData and exposes storage-oriented abstractions.

The package contains a distinction between:

- `StorageCore`
- `Storage`

`StorageCore` contains lower-level storage/domain contracts and entities.

`Storage` contains the concrete SwiftData-backed implementation and higher-level storage behaviour.

Do not make the API package depend on Storage.

Do not make Storage depend on UI.

Do not place SwiftData persistence logic in `Radio/Middleware` when it belongs naturally inside `Storage`.

---

## 14. API Models vs Persistence Models

API models and persistence models are intentionally separated.

For example, `Station` data coming from `RadioBrowserAPI` is adapted into storage records in the application layer.

The mapping is currently implemented through adapters such as:

```swift
extension StationRecord {
    init(from station: some Station) { ... }
}
```

Preserve this direction:

```text
RadioBrowserAPI
       ↓
application adapter
       ↓
Storage DTO / entity
       ↓
SwiftData
```

Do not make persistence entities depend directly on API package types merely to avoid writing mapping code.

The adapter boundary is intentional.

---

## 15. Storage Filtering

Station filtering has both persistence-level and in-memory behaviour.

The current storage strategy distinguishes between:

- operations that can be pushed into SQLite/SwiftData;
- operations that must be performed in memory.

Examples include:

- name/country/language predicates;
- SQLite-compatible ordering;
- tag filtering;
- ordering by `lastCheckOk`;
- offset/limit windowing.

When changing filtering behaviour, preserve parity between:

1. the persistence query path;
2. the in-memory path;
3. post-processing;
4. ordering;
5. pagination/windowing.

Do not add a filter to only one path.

When possible, define the behaviour once and derive both implementations from the same semantic rule.

Existing tests around filtering and storage are important regression protection.

---

## 16. Storage Performance

Large station imports can involve tens of thousands of records.

Avoid unnecessary work on the main actor.

When processing large collections:

- avoid unnecessary intermediate copies;
- avoid repeated conversions;
- avoid performing CPU-heavy mapping on the main actor;
- use the existing background storage behaviour where appropriate.

Performance changes must not compromise correctness or actor isolation.

Do not optimize based on assumptions; inspect the actual data flow first.

---

## 17. UI Library

`Packages/UILibrary` contains reusable SwiftUI components.

Current examples include:

- `StationListView`
- `SearchView`
- `StationRowView`
- `TagView`
- `TagsCloudView`
- `EmptySearchView`

The UI library should remain reusable and application-agnostic.

Do not make reusable UI components depend directly on:

- `RadioBrowserAPI`;
- SwiftData;
- application services;
- Needle;
- platform-specific application composition.

Pass the data and actions required by the component through its API.

---

## 18. SwiftUI

Prefer modern SwiftUI composition.

Keep views focused on:

- presentation;
- local UI state;
- user interaction;
- rendering.

Avoid turning a View into a networking, persistence, or dependency-injection container.

When business logic becomes substantial, move it to an appropriate application/domain/service layer.

Do not introduce a ViewModel automatically for every view. Use one when the view has meaningful state transformation, asynchronous behaviour, or a stable presentation boundary that benefits from it.

---

## 19. Cross-Platform Code

The application targets both iOS and macOS.

Shared application logic should remain platform-independent where possible.

Use conditional compilation only when platform behaviour genuinely differs.

Prefer shared SwiftUI components and shared middleware over duplicated platform implementations.

Platform entry points belong under:

```text
Radio/iOS/
Radio/macOS/
```

Do not put iOS-specific APIs into code that is compiled for macOS.

When modifying shared `Radio/Middleware` code, verify both platform targets conceptually and, where possible, by building both.

---

## 20. Testing

Tests exist inside individual Swift packages.

Relevant test suites include:

- `ArchitectureTests`
- `RadioBrowserAPITests`
- `StorageTests`

When changing package behaviour, add or update tests in the package that owns the behaviour.

Prefer focused unit tests over application-level tests when the behaviour belongs to a package.

For storage changes, pay particular attention to:

- filtering;
- ordering;
- pagination;
- persistence;
- failure propagation;
- async behaviour;
- in-memory vs persistent storage;
- parity between query paths.

For API changes, test:

- decoding;
- endpoint construction;
- errors;
- network behaviour;
- failover behaviour where relevant.

---

## 21. Previews and Test Data

`UILibrary` contains preview/mock data such as `MockStations`.

Use deterministic mock data for SwiftUI previews and UI tests.

Do not make previews depend on live network services.

Do not require a persistent on-disk database for a preview.

Storage already supports in-memory containers for isolated testing and previews; prefer that mechanism rather than introducing temporary persistence.

---

## 22. Generated Code and Tooling

Do not manually edit generated files.

The repository contains generated-code exclusions for items such as:

- `NeedleGenerated.swift`
- generated RadioBrowser API files
- `*.generated.swift`
- `R.generated.swift`

When generated code must change, update the source/configuration that produces it and regenerate.

Do not modify generated output merely to fix a compile error.

---

## 23. Dependencies

Before adding a dependency:

1. Check whether the existing stack already provides the required functionality.
2. Check whether the functionality belongs in an existing local package.
3. Consider whether a small local implementation is preferable.
4. Consider the impact on iOS/macOS targets.
5. Avoid adding a dependency for trivial functionality.

External dependencies should be declared through the appropriate package/project configuration, not hard-coded into source files.

Do not silently upgrade unrelated dependencies while implementing a feature.

---

## 24. Git and Changes

Keep changes focused.

Do not:

- modify unrelated files;
- reformat unrelated code;
- change package architecture while implementing a small feature;
- remove existing tests;
- disable linting or concurrency checks to make a change pass;
- overwrite user changes;
- reset or discard changes you did not create.

Before completing a task:

1. inspect the final diff;
2. confirm that only relevant files changed;
3. run the strongest practical checks;
4. report anything that could not be verified.

---

## 25. Project Configuration Changes

When modifying project configuration:

- use `project.yml` for XcodeGen configuration;
- use `Package.swift` for Swift package dependencies and targets;
- use `.swiftlint.yml` for shared linting policy.

Do not duplicate configuration between these files without a reason.

If the same rule or dependency is configured at multiple levels, understand which layer owns it before changing it.

---

## 26. Agent Workflow

For a non-trivial task, follow this workflow:

1. Identify which package/layer owns the behaviour.
2. Search for existing implementations and protocols.
3. Inspect callers and consumers.
4. Inspect relevant tests.
5. Make the smallest coherent change.
6. Add/update tests.
7. Run SwiftLint and relevant package tests/builds.
8. Inspect the final diff.
9. Update documentation when an architectural contract changes.

Search before creating.

Reuse before abstracting.

Do not perform broad refactors unless they are required by the task.

---

## 27. Handling Ambiguity

If the task is ambiguous but has an obvious local implementation that follows existing architecture, proceed.

Ask for clarification when the ambiguity affects:

- public API design;
- package boundaries;
- persistence schema;
- concurrency/actor isolation;
- dependency direction;
- architectural contracts;
- user-visible behaviour with multiple materially different interpretations.

Do not invent architectural decisions silently.

---

## 28. Completion Criteria

A task is not complete merely because the code compiles in isolation.

Where applicable, completion means:

- implementation matches the existing architecture;
- package boundaries remain valid;
- SwiftLint passes;
- relevant tests pass;
- concurrency diagnostics are resolved correctly;
- generated project/package configuration remains consistent;
- no unrelated files were changed;
- the final diff was inspected.

If a check cannot be run, state that explicitly.

Never claim a test, build, lint, generation step, or verification was performed when it was not.

---

## 29. Priority of Rules

When deciding how to implement a task, use this priority:

1. Explicit user/task requirements.
2. Existing public API and architectural contracts.
3. Package boundaries and dependency direction.
4. Existing tests.
5. Existing project conventions.
6. General Swift engineering best practices.

If two rules appear to conflict, investigate the surrounding code and tests before choosing an interpretation.

Do not silently introduce a third architectural pattern.

---

## 30. Keep This File Focused

This file defines project-wide rules for AI agents.

Do not turn it into a complete description of every package or every class.

Detailed design information should live with the package or in dedicated documentation.

The purpose of this file is to make an AI agent safe and predictable when modifying the repository.
