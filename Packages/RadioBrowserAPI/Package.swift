// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "RadioBrowserAPI",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "RadioBrowserAPI",
            targets: ["RadioBrowserAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.65.1")
    ],
    targets: [
        .target(
            name: "RadioBrowserAPI",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]),
        .testTarget(
            name: "RadioBrowserAPITests",
            dependencies: ["RadioBrowserAPI"],
            resources: [.process("Mocks/Data")],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency=complete")],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ])
    ],
)
