// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "UILibrary",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "UILibrary",
            targets: ["UILibrary"]),
    ],
    dependencies: [
        .package(path: "../Resources"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.65.1")
    ],
    targets: [
        .target(
            name: "UILibrary",
            dependencies: [
                .product(name: "Resources", package: "Resources")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]),
    ]
)
