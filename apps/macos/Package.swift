// swift-tools-version: 6.2
// Package manifest for the DMMS AI macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "DMMS AI",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "DmmsAiIPC", targets: ["DmmsAiIPC"]),
        .library(name: "DmmsAiDiscovery", targets: ["DmmsAiDiscovery"]),
        .executable(name: "DMMS AI", targets: ["DMMS AI"]),
        .executable(name: "dmms-ai-mac", targets: ["DmmsAiMacCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MenuBarExtraAccess", exact: "1.2.2"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.8.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.1"),
        .package(url: "https://github.com/steipete/Peekaboo.git", branch: "main"),
        .package(path: "../shared/DmmsAiKit"),
        .package(path: "../../Swabble"),
    ],
    targets: [
        .target(
            name: "DmmsAiIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "DmmsAiDiscovery",
            dependencies: [
                .product(name: "DmmsAiKit", package: "DmmsAiKit"),
            ],
            path: "Sources/DmmsAiDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "DMMS AI",
            dependencies: [
                "DmmsAiIPC",
                "DmmsAiDiscovery",
                .product(name: "DmmsAiKit", package: "DmmsAiKit"),
                .product(name: "DmmsAiChatUI", package: "DmmsAiKit"),
                .product(name: "DmmsAiProtocol", package: "DmmsAiKit"),
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
                .copy("Resources/DMMS AI.icns"),
                .copy("Resources/DeviceModels"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "DmmsAiMacCLI",
            dependencies: [
                "DmmsAiDiscovery",
                .product(name: "DmmsAiKit", package: "DmmsAiKit"),
                .product(name: "DmmsAiProtocol", package: "DmmsAiKit"),
            ],
            path: "Sources/DmmsAiMacCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "DmmsAiIPCTests",
            dependencies: [
                "DmmsAiIPC",
                "DMMS AI",
                "DmmsAiDiscovery",
                .product(name: "DmmsAiProtocol", package: "DmmsAiKit"),
                .product(name: "SwabbleKit", package: "swabble"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
