# Radio App — AI Agent Instructions

## 1. Project Overview

Radio is a cross-platform Apple application for browsing and working with Internet radio stations.

The application targets:

- iOS 17+
- macOS 14+
- Swift 6.4

The `UILibrary` and `Resources` packages declare lower minimums (iOS 15+, macOS 12+) so they remain reusable; do not raise them without a reason.

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
2. Read the `AGENTS.md` for the package you are changing (see §5).
3. Inspect the relevant Swift Package and its public interfaces.
4. Inspect `project.yml` if the change affects targets, dependencies, build settings, or generated Xcode configuration.
5. Check existing tests.
6. Preserve established module boundaries.

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
- SwiftLint (via the `SwiftLintPlugins` build-tool plugin)
- R.swift (via a build-tool plugin in the `Resources` package)
- iOS 17+ (application), macOS 14+ (application)

`RadioBrowserAPI` enables strict concurrency checking; other packages do not enable it explicitly but should still be concurrency-correct. See §8 and the package's `AGENTS.md`.

Do not introduce another dependency-injection framework, networking framework, persistence framework, or UI framework without an explicit reason and approval.

Prefer the technologies already used by the affected module.

---

## 4. Repository Structure

The main application and package boundaries are:

```text
Radio/
├── iOS/            (iOS entry points, Info.plist)
├── macOS/          (macOS entry points, Info.plist)
├── Middleware/      (services, adapters, DI components)
├── Flow/           (launch flow coordinator/views/view model)
├── Generated/      (NeedleGenerated.swift, gitignored)
├── Assets.xcassets/
└── needle.yml      (Needle CLI codegen scope)

Packages/
├── Architecture/     (has its own AGENTS.md)
├── RadioBrowserAPI/  (has its own AGENTS.md)
├── Storage/          (has its own AGENTS.md)
├── UILibrary/        (has its own AGENTS.md)
└── Resources/        (has its own AGENTS.md)

project.yml
.swiftlint.yml
```

### Application

`Radio/` contains platform entry points and application-layer composition.

`Radio/Middleware/` contains application-level services and adapters connecting domain/package APIs.

### Packages

Each package owns a focused responsibility and is documented by its own `AGENTS.md`:

- `Architecture` — shared architectural protocols and lightweight abstractions.
- `RadioBrowserAPI` — Radio Browser API client, models, decoding, routing, networking, and API-related errors.
- `Storage` — persistence and storage abstractions built around SwiftData.
- `UILibrary` — reusable SwiftUI UI components and UI-facing models.
- `Resources` — shared application resources.

Do not bypass package boundaries simply because importing another module appears convenient.

---

## 5. Package-Specific Instructions

Each local package has its own `AGENTS.md` with rules scoped to that package. Read it before editing that package.

| Package | File |
| --- | --- |
| Architecture | `Packages/Architecture/AGENTS.md` |
| RadioBrowserAPI | `Packages/RadioBrowserAPI/AGENTS.md` |
| Storage | `Packages/Storage/AGENTS.md` |
| UILibrary | `Packages/UILibrary/AGENTS.md` |
| Resources | `Packages/Resources/AGENTS.md` |

For code inside a package, that package's `AGENTS.md` is more specific than this file. It does not override the dependency-direction and boundary rules defined here.

---

## 6. XcodeGen

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

## 7. Swift Style

Follow the repository's `.swiftlint.yml`.

The root `.swiftlint.yml` is the shared policy. Each package also has a small wrapper config (`parent_config: ../../.swiftlint.yml` plus `strict: true`) because the build-tool plugin runs with the package directory as its working directory; keep these wrappers in sync with the root config.

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

## 8. Swift Concurrency

The project uses Swift 6.4 and concurrency-aware APIs.

`RadioBrowserAPI` explicitly enables:

```swift
.enableExperimentalFeature("StrictConcurrency=complete")
```

Other packages do not enable it explicitly, but should still be concurrency-correct. See the package `AGENTS.md` for package-specific concurrency notes.

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

## 9. Main Actor

UI-facing and application objects that interact with SwiftUI or UI state may be `@MainActor`.

Existing application services such as `AppComponent`, `AppInitializer`, and `StationsService` use main-actor isolation.

Preserve existing actor isolation when extending these types.

Do not remove `@MainActor` merely to make an API easier to call.

When moving expensive work away from the main actor, keep the public orchestration clear and return to the appropriate actor only when necessary.

---

## 10. Dependency Injection

The application uses Needle / NeedleFoundation for dependency injection.

The `Architecture` package also contains lightweight dependency-resolution abstractions (`DependencyResolver`, `DependencyProvider`, `ModuleResolver`, `ModuleFactoryProtocol`, `ModuleProtocol`, `CoordinatorProtocol`, `NavigatorProtocol`). See `Packages/Architecture/AGENTS.md`.

Do not introduce a second dependency-injection mechanism for the same application layer.

Prefer constructor injection for ordinary dependencies.

Use the existing Needle composition root for application-level dependency graphs.

A service should not reach into global state to obtain dependencies that can be injected.

---

## 11. Application Layer

`Radio/Middleware` is the application composition layer between infrastructure packages and the UI/application entry points.

Current examples include:

- `AppInitializer`
- `AppComponent`
- `RootValuesComponent`, `ApiComponent`, `StorageComponent`, `LaunchComponent`
- `StationsService`
- `CountriesService`
- `LanguagesService`
- `TagsService`
- `CodecsService`
- adapters such as `StationAdapter`, `CountryAdapter`, `LanguageAdapter`, `TagAdapter`, `CodecAdapter`

Application services may coordinate multiple packages.

They should not become replacements for the underlying packages.

For example:

- API concerns belong in `RadioBrowserAPI`.
- persistence concerns belong in `Storage`.
- reusable UI belongs in `UILibrary`.
- application orchestration belongs in `Radio/Middleware`.

---

## 12. API Models vs Persistence Models

API models and persistence models are intentionally separated. This boundary spans the application layer, `RadioBrowserAPI`, and `Storage`.

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

## 13. SwiftUI

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

## 14. Cross-Platform Code

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

## 15. Testing

Tests live inside individual Swift packages. Each package's `AGENTS.md` describes its own suite and focus areas.

- Most suites use Swift Testing (`import Testing`, `@Test`, `#expect`); `ArchitectureTests` still uses XCTest.
- `UILibrary` and `Resources` currently have no test targets.
- Run a package's tests with `swift test` from the package directory.
- `RadioBrowserAPI` has an opt-in live-network suite (`RADIO_BROWSER_LIVE_TESTS=1 swift test --filter LiveServiceTests`).

When changing package behaviour, add or update tests in the package that owns the behaviour.

Prefer focused unit tests over application-level tests when the behaviour belongs to a package.

---

## 16. Previews and Test Data

Use deterministic mock data for SwiftUI previews and UI tests. `UILibrary` provides preview data such as `MockStations`.

Do not make previews depend on live network services.

Do not require a persistent on-disk database for a preview.

`Storage` supports in-memory containers for isolated testing and previews; prefer that mechanism rather than introducing temporary persistence.

---

## 17. Generated Code and Tooling

Do not manually edit generated files.

The repository contains generated-code exclusions for items such as:

- `NeedleGenerated.swift`
- generated RadioBrowser API files
- `*.generated.swift`
- `R.generated.swift`

Code generation is driven by:

- the `needle` CLI (Homebrew), invoked by an XcodeGen pre-build script scoped to `Radio/Middleware` via `Radio/needle.yml`, producing `Radio/Generated/NeedleGenerated.swift`;
- the R.swift build-tool plugin, producing `R.generated.swift` for the `Resources` package.

When generated code must change, update the source/configuration that produces it and regenerate.

Do not modify generated output merely to fix a compile error.

---

## 18. Dependencies

Before adding a dependency:

1. Check whether the existing stack already provides the required functionality.
2. Check whether the functionality belongs in an existing local package.
3. Consider whether a small local implementation is preferable.
4. Consider the impact on iOS/macOS targets.
5. Avoid adding a dependency for trivial functionality.

External dependencies should be declared through the appropriate package/project configuration, not hard-coded into source files.

Do not silently upgrade unrelated dependencies while implementing a feature.

---

## 19. Git and Changes

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

## 20. Project Configuration Changes

When modifying project configuration:

- use `project.yml` for XcodeGen configuration;
- use `Package.swift` for Swift package dependencies and targets;
- use `.swiftlint.yml` for shared linting policy.

Note that each package has a thin `.swiftlint.yml` wrapper (`parent_config: ../../.swiftlint.yml` + `strict: true`) because the build-tool plugin's working directory is the package root; update the root config as the policy owner and keep the wrappers minimal.

Do not duplicate configuration between these files without a reason.

If the same rule or dependency is configured at multiple levels, understand which layer owns it before changing it.

---

## 21. Agent Workflow

For a non-trivial task, follow this workflow:

1. Identify which package/layer owns the behaviour.
2. Read that layer's `AGENTS.md` (see §5).
3. Search for existing implementations and protocols.
4. Inspect callers and consumers.
5. Inspect relevant tests.
6. Make the smallest coherent change.
7. Add/update tests.
8. Run SwiftLint and relevant package tests/builds.
9. Inspect the final diff.
10. Update documentation when an architectural contract changes.

Search before creating.

Reuse before abstracting.

Do not perform broad refactors unless they are required by the task.

---

## 22. Handling Ambiguity

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

## 23. Completion Criteria

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

## 24. Priority of Rules

When deciding how to implement a task, use this priority:

1. Explicit user/task requirements.
2. Existing public API and architectural contracts.
3. Package boundaries and dependency direction.
4. Existing tests.
5. Existing project conventions, including the package's own `AGENTS.md` for package-local code.
6. General Swift engineering best practices.

If two rules appear to conflict, investigate the surrounding code and tests before choosing an interpretation.

Do not silently introduce a third architectural pattern.

---

## 25. Keep This File Focused

This file defines project-wide and application-layer rules for AI agents.

Package-specific rules belong in each package's own `AGENTS.md` under `Packages/<Name>/AGENTS.md`.

Do not turn this file into a complete description of every package or every class.

The purpose of this file is to make an AI agent safe and predictable when modifying the repository.
