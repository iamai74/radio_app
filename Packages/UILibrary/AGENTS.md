# UILibrary Package — AI Agent Instructions

Package-scoped rules for `Packages/UILibrary`. Project-wide rules live in the repository root `AGENTS.md`; read that first. The root SwiftUI and preview guidance also applies here.

## Purpose

Reusable, application-agnostic SwiftUI components and UI-facing models.

## Deployment target

This package declares iOS 17+ and macOS 14+. Platform-specific APIs used in this package include conditional image construction in `AsyncImageLoaderView` (`#if os(iOS)` / `#if os(macOS)`). Do not introduce additional platform branching without a reason.

## Structure

```
Sources/UILibrary/
├── Models/
│   ├── Station.swift              — UI-facing Station protocol (Identifiable, Hashable, Sendable)
│   ├── AppColor.swift             — Application color palette enum
│   ├── AppImage.swift             — SF Symbols system image registry enum
│   └── AudioFrequencyBands.swift  — Frequency data model for audio visualization
├── Mock/
│   ├── MockStations.swift         — MockStation struct, MockStations collection
│   └── MockStrings.swift          — Deterministic preview strings
└── Views/
    ├── PlayerView.swift           — Station player with vertical/horizontal layouts
    ├── StationsListView.swift     — Responsive grid list of stations
    ├── StationRowView.swift       — Horizontal/vertical station row card
    ├── StationFilterView.swift    — Segmented filter picker (All / Favorites)
    ├── SearchFieldView.swift      — Search text field with icon
    ├── NoResultView.swift         — Empty-state placeholder view
    ├── AvatarView.swift           — Favicon avatar with initials fallback and loading state
    ├── BlurView.swift             — Material blur rectangle
    ├── AsyncImageLoaderView.swift — Async network image loader (platform-specific image construction)
    ├── LoadingIndicator.swift     — Animated dot-circle loading spinner
    ├── AudioVisualizerView.swift  — Audio frequency visualization (columns / wave)
    ├── TagsCloudView.swift        — Wrapping tag cloud with custom Layout (TagFlowLayout)
    ├── Buttons/
    │   └── FavoriteButton.swift   — Toggle favorite star button
    ├── Text/
    │   ├── TextView.swift         — Styled text view
    │   ├── TextStyles.swift       — TextSize and TextColorStyle enums
    │   ├── TagView.swift          — Pill-shaped tag label
    │   └── RepeatableTexts.swift  — StationNameTextView shorthand
    ├── Label/
    │   ├── LabelView.swift        — Icon + text label with configurable alignment
    │   └── RepeatableLabels.swift — CountryLabelView, BitrateLabelView
    └── Animation/
        ├── GradientView.swift     — Animated gradient with GradientAnimator (ObservableObject, @MainActor)
        ├── SeaSurfGradientView.swift — Ocean-inspired animated gradient background
        └── SeaWaveView.swift      — Animated wave shape layers
```

## Types

| Type | Kind | Purpose |
| --- | --- | --- |
| `Station` | protocol | UI-facing station model, `Identifiable + Hashable + Sendable` |
| `PlayerLayout` | enum | `.vertical`, `.horizontal` player orientations |
| `StationRowLayout` | enum | `.horizontal`, `.vertical` row orientations |
| `StationsFilter` | enum | `.all`, `.favorites` filter cases |
| `LabelAlignment` | enum | `.leadingIcon`, `.trailingIcon` |
| `TextSize` | enum | Typography scale (h1–h4, base, subheadline, caption) |
| `TextColorStyle` | enum | `.primary`, `.secondary`, `.accent`, `.white` |
| `AppColor` | enum | Application color palette with `.color` computed property |
| `AppImage` | enum | SF Symbols registry with `.name` and `.view` properties |
| `AudioFrequencyBands` | struct | Frequency band data, `.empty()` and `.random()` factories |
| `GradientAnimator` | class | `@MainActor ObservableObject` that animates gradient colors and points |

## Concurrency

- `Station` is `Sendable`.
- `GradientAnimator` is `@MainActor` and uses `Task` for background animation work with proper cancellation.
- `AsyncImageLoaderView` uses `@MainActor` async load via `.task`.
- Animation views (`SeaSurfGradientView`, `SeaWaveView`, `LoadingIndicator`) use `TimelineView(.animation)` — no additional concurrency concerns.

Do not remove `@MainActor` or `Sendable` annotations without understanding the isolation boundaries.

## Rules

- Keep components reusable and application-agnostic.
- Do not depend on `RadioBrowserAPI`, SwiftData, application services, Needle, or platform-specific application composition.
- Pass the data and actions a component needs through its API (parameters, bindings, closures).
- Do not make previews depend on live network services or a persistent on-disk database; use deterministic mock data (`MockStations`, `MockStrings`).
- Mock types (`MockStation`, `MockStations`, `MockStrings`) are internal; do not expose them publicly or depend on them outside this package.
- Prefer parameterized views over hard-coded strings. Views should receive titles, labels, and placeholders from their caller.

## Testing

There is currently no test target in this package.
