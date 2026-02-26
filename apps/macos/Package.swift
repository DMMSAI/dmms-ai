// swift-tools-version: 6.2
// Package manifest for the Dryads AI macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "Dryads AI",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "DryadsAiIPC", targets: ["DryadsAiIPC"]),
        .library(name: "DryadsAiDiscovery", targets: ["DryadsAiDiscovery"]),
        .executable(name: "Dryads AI", targets: ["Dryads AI"]),
        .executable(name: "dryads-ai-mac", targets: ["DryadsAiMacCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MenuBarExtraAccess", exact: "1.2.2"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.8.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.1"),
        .package(url: "https://github.com/steipete/Peekaboo.git", branch: "main"),
        .package(path: "../shared/DryadsAiKit"),
        .package(path: "../../Swabble"),
    ],
    targets: [
        .target(
            name: "DryadsAiIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "DryadsAiDiscovery",
            dependencies: [
                .product(name: "DryadsAiKit", package: "DryadsAiKit"),
            ],
            path: "Sources/DryadsAiDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "Dryads AI",
            dependencies: [
                "DryadsAiIPC",
                "DryadsAiDiscovery",
                .product(name: "DryadsAiKit", package: "DryadsAiKit"),
                .product(name: "DryadsAiChatUI", package: "DryadsAiKit"),
                .product(name: "DryadsAiProtocol", package: "DryadsAiKit"),
                .product(name: "SwabbleKit", package: "swabble"),
                .product(name: "MenuBarExtraAccess", package: "MenuBarExtraAccess"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "PeekabooBridge", package: "Peekaboo"),
                .product(name: "PeekabooAutomationKit", package: "Peekaboo"),
            ],
            exclude: [
                "Resources/Info.plist",
            ],
            resources: [
                .copy("Resources/Dryads AI.icns"),
                .copy("Resources/DeviceModels"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "DryadsAiMacCLI",
            dependencies: [
                "DryadsAiDiscovery",
                .product(name: "DryadsAiKit", package: "DryadsAiKit"),
                .product(name: "DryadsAiProtocol", package: "DryadsAiKit"),
            ],
            path: "Sources/DryadsAiMacCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "DryadsAiIPCTests",
            dependencies: [
                "DryadsAiIPC",
                "Dryads AI",
                "DryadsAiDiscovery",
                .product(name: "DryadsAiProtocol", package: "DryadsAiKit"),
                .product(name: "SwabbleKit", package: "swabble"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
