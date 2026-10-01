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
        .package(path: "../Resources")
    ],
    targets: [
        .target(
            name: "UILibrary",
            dependencies: [
                .product(name: "Resources", package: "Resources")
            ]),
    ]
)
