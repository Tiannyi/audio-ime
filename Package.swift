// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "AudioIME",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(name: "AudioIMECore", targets: ["AudioIMECore"]),
        .library(name: "AudioIMEMacOS", targets: ["AudioIMEMacOS"]),
        .library(name: "AudioIMEiOS", targets: ["AudioIMEiOS"]),
        .library(name: "ConversationTracker", targets: ["ConversationTracker"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.42.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "AudioIMECore",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/AudioIMECore",
            swiftSettings: [.define("SWIFT_PACKAGE")]
        ),
        .target(
            name: "AudioIMEMacOS",
            dependencies: ["AudioIMECore"],
            path: "Sources/AudioIMEMacOS",
            swiftSettings: [.define("SWIFT_PACKAGE")]
        ),
        .target(
            name: "AudioIMEiOS",
            dependencies: ["AudioIMECore"],
            path: "Sources/AudioIMEiOS",
            swiftSettings: [.define("SWIFT_PACKAGE")]
        ),
        .target(
            name: "ConversationTracker",
            dependencies: [
                "AudioIMECore",
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/ConversationTracker",
            swiftSettings: [.define("SWIFT_PACKAGE")]
        ),
        .testTarget(
            name: "AudioIMECoreTests",
            dependencies: ["AudioIMECore"],
            path: "Tests/AudioIMECoreTests"
        ),
        .testTarget(
            name: "AudioIMEMacOSTests",
            dependencies: ["AudioIMEMacOS"],
            path: "Tests/AudioIMEMacOSTests"
        ),
        .testTarget(
            name: "AudioIMEiOSTests",
            dependencies: ["AudioIMEiOS"],
            path: "Tests/AudioIMEiOSTests"
        ),
        .testTarget(
            name: "ConversationTrackerTests",
            dependencies: ["ConversationTracker"],
            path: "Tests/ConversationTrackerTests"
        )
    ]
)
