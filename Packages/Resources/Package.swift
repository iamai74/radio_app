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
    dependencies: [
        .package(url: "https://github.com/mac-cain13/R.swift", from: "7.5.0"),
    ],
    targets: [
        .target(
            name: "Resources",
            dependencies: [.product(name: "RswiftLibrary", package: "R.swift")],
            resources: [.process("en.lproj"), .process("ru.lproj")],
            plugins: [
                .plugin(name: "RswiftGeneratePublicResources", package: "R.swift"),
            ]),
    ]
)
