// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Architecture",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Architecture",
            targets: ["Architecture"]),
    ],
    dependencies: [
        .package(url: "https://github.com/uber/needle.git", from: "0.1.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.65.1")
    ],
    targets: [
        .target(
            name: "Architecture",
            dependencies: [
                .product(name: "NeedleFoundation", package: "needle")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]),
        .testTarget(
            name: "ArchitectureTests",
            dependencies: ["Architecture"]),
    ]
)
