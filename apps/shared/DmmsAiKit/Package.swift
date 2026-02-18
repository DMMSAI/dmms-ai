// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DmmsAiKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "DmmsAiProtocol", targets: ["DmmsAiProtocol"]),
        .library(name: "DmmsAiKit", targets: ["DmmsAiKit"]),
        .library(name: "DmmsAiChatUI", targets: ["DmmsAiChatUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/ElevenLabsKit", exact: "0.1.0"),
        .package(url: "https://github.com/gonzalezreal/textual", exact: "0.3.1"),
    ],
    targets: [
        .target(
            name: "DmmsAiProtocol",
            path: "Sources/DmmsAiProtocol",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "DmmsAiKit",
            dependencies: [
                "DmmsAiProtocol",
                .product(name: "ElevenLabsKit", package: "ElevenLabsKit"),
            ],
            path: "Sources/DmmsAiKit",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "DmmsAiChatUI",
            dependencies: [
                "DmmsAiKit",
                .product(
                    name: "Textual",
                    package: "textual",
                    condition: .when(platforms: [.macOS, .iOS])),
            ],
            path: "Sources/DmmsAiChatUI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "DmmsAiKitTests",
            dependencies: ["DmmsAiKit", "DmmsAiChatUI"],
            path: "Tests/DmmsAiKitTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
