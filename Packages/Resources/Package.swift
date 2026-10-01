// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Resources",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Resources",
            targets: ["Resources"]),
    ],
    targets: [
        .target(
            name: "Resources",
            dependencies: [],
            sources: ["Localization"],
            resources: [.process("Resources")]),
    ]
)
