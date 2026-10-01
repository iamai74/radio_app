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
        .package(url: "https://github.com/uber/needle.git", from: "0.25.0")
    ],
    targets: [
        .target(
            name: "RadioBrowserAPI",
            dependencies: [
                .product(name: "NeedleFoundation", package: "needle")
            ]),
    ]
)
