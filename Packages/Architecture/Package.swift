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
        .package(url: "https://github.com/uber/needle.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Architecture",
            dependencies: [
                .product(name: "NeedleFoundation", package: "needle")
            ]),
        .testTarget(
            name: "ArchitectureTests",
            dependencies: ["Architecture"]),
    ]
)
