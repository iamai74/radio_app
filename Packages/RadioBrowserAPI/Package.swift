// swift-tools-version: 5.9

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
        .package(url: "https://github.com/uber/needle.git", from: "0.25.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.65.1")
    ],
    targets: [
        .target(
            name: "RadioBrowserAPI",
            dependencies: [
                .product(name: "NeedleFoundation", package: "needle")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]),
    ]
)
