# Resources Package — AI Agent Instructions

Package-scoped rules for `Packages/Resources`. Project-wide rules live in the repository root `AGENTS.md`; read that first.

## Purpose

Shared application resources (localizations and similar assets).

## Deployment target

Declares lower minimums (iOS 15+, macOS 12+) than the application. Do not raise them without a reason.

## R.swift

The package uses the R.swift build-tool plugin (`RswiftGeneratePublicResources`), which generates `R.generated.swift` at build time. It is not tracked; do not edit generated output. Change the underlying resources or configuration instead.

Localizations currently include `en` and `ru` (`Localizable.strings`).

## Testing

There is currently no test target in this package.
