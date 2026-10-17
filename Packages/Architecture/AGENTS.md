# Architecture Package — AI Agent Instructions

Package-scoped rules for `Packages/Architecture`. Project-wide rules live in the repository root `AGENTS.md`; read that first.

## Purpose

`Architecture` defines shared architectural contracts and lightweight abstractions used across the application. It is a contracts/boundary package, not a place for concrete feature logic.

This package must not depend on any other local package.

## Key concepts

- `ViewModelProtocol` (`@MainActor`) — input/output transform contract.
- `ViewProtocol` (`@MainActor`) — a `View` with an associated view-model type.
- `NavigatorProtocol` (`@MainActor`) — navigation intents (`setRoot`/`push`/`present`/`pop`).
- `CoordinatorProtocol` (`@MainActor`) — owns a `navigator` and `start()`.
- `ModuleProtocol` — builds a coordinator for a given navigator.
- `ModuleFactoryProtocol` / `DefaultModuleFactory` — resolve modules into coordinators.
- `DependencyResolver` — `resolve<T>(_:)`.
- `DependencyProvider` — dependency holder with an associated resolver.
- `ModuleResolver` — a lightweight keyed registry implementing `DependencyResolver`.

## Rules

- These are architectural boundaries, not a requirement to force every new type into a protocol.
- Do not create protocols solely because "every class should have a protocol". Create one when a boundary requires abstraction, dependency injection benefits from substitution, tests need a meaningful seam, multiple implementations are expected, or the abstraction represents a stable contract.
- Avoid speculative abstractions.
- `ModuleResolver` and `DefaultModuleFactory` currently exist but are not wired into the application composition (the app uses Needle). Do not introduce them as a second DI mechanism without a reason.
- Preserve the existing `@MainActor` isolation on the UI-facing contracts.

## Testing

- Suite: `ArchitectureTests` — the only suite in the repository that still uses **XCTest**.
- Run with `swift test` from `Packages/Architecture`.
