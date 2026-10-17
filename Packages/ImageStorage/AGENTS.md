# ImageStorage Package — AI Agent Instructions

Package-scoped rules for `Packages/ImageStorage`. Project-wide rules live in the repository root `AGENTS.md`; read that first.

## Purpose

`ImageStorage` provides file-based image caching using the app's Documents directory.
It stores downloaded images (station icons, country flags, etc.) keyed by a string identifier
and returns file URLs or raw data for retrieval.

## Structure

```
Sources/ImageStorage/
├── ImageStorageProtocol.swift   # Public protocol
├── DefaultImageStorage.swift    # Concrete implementation
├── FileManagerProtocol.swift    # Testable file I/O abstraction
└── ImageStorageError.swift      # Domain errors
```

## Key Concepts

- Images are stored by a deterministic key (e.g., URL hash or identifier).
- The package writes to the Documents directory via ``FileManagerProtocol``.
- All public APIs are async to allow file I/O off the main actor.
- The protocol is the primary abstraction; callers depend on ``ImageStorageProtocol``, not the concrete type.

## Rules

- Keep the package self-contained; do not import other local packages.
- Use `URLSession` for any future download helpers; do not introduce networking dependencies.
- Prefer `async`/`await` over completion handlers.
- File paths must be scoped to the Documents directory; never expose arbitrary paths.
- Store images with safe filenames to avoid path traversal issues.

## Testing

Tests use temporary directories to isolate file I/O.
No persistent side effects should leak from the test suite.
