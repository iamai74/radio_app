# UILibrary Package — AI Agent Instructions

Package-scoped rules for `Packages/UILibrary`. Project-wide rules live in the repository root `AGENTS.md`; read that first. The root SwiftUI and preview guidance also applies here.

## Purpose

Reusable, application-agnostic SwiftUI components and UI-facing models.

## Deployment target

This package declares lower minimums (iOS 15+, macOS 12+) than the application so it stays reusable. Do not raise them without a reason.

## Components

`StationsListView`, `StationRowView`, `StationFilterView`, `SearchFieldView`, `TagView`, `TagsCloudView`, `NoResultView`, `AvatarView`, `PlayerView`, `LoadingIndicator`, `TextView`, `SeaSurfGradientView`.

Preview/mock data (`MockStations`, `MockStation`) and the UI-facing `Station` protocol also live in this package.

## Rules

- Keep components reusable and application-agnostic.
- Do not depend on `RadioBrowserAPI`, SwiftData, application services, Needle, or platform-specific application composition.
- Pass the data and actions a component needs through its API.
- Do not make previews depend on live network services or a persistent on-disk database; use deterministic mock data and in-memory storage.

## Testing

There is currently no test target in this package.
