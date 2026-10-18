// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "UILibrary",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "UILibrary",
            targets: ["UILibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.65.1")
    ],
    targets: [
        .target(
            name: "UILibrary",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]),
    ]
)
