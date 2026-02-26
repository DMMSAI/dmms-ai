// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DryadsAiKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "DryadsAiProtocol", targets: ["DryadsAiProtocol"]),
        .library(name: "DryadsAiKit", targets: ["DryadsAiKit"]),
        .library(name: "DryadsAiChatUI", targets: ["DryadsAiChatUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/ElevenLabsKit", exact: "0.1.0"),
        .package(url: "https://github.com/gonzalezreal/textual", exact: "0.3.1"),
    ],
    targets: [
        .target(
            name: "DryadsAiProtocol",
            path: "Sources/DryadsAiProtocol",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "DryadsAiKit",
            dependencies: [
                "DryadsAiProtocol",
                .product(name: "ElevenLabsKit", package: "ElevenLabsKit"),
            ],
            path: "Sources/DryadsAiKit",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "DryadsAiChatUI",
            dependencies: [
                "DryadsAiKit",
                .product(
                    name: "Textual",
                    package: "textual",
                    condition: .when(platforms: [.macOS, .iOS])),
            ],
            path: "Sources/DryadsAiChatUI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "DryadsAiKitTests",
            dependencies: ["DryadsAiKit", "DryadsAiChatUI"],
            path: "Tests/DryadsAiKitTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
