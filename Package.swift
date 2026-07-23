// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Knopo",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "KnopoCore", targets: ["KnopoCore"]),
        .executable(name: "Knopo", targets: ["Knopo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "KnopoCore",
            dependencies: [.product(name: "GRDB", package: "GRDB.swift")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .executableTarget(
            name: "Knopo",
            dependencies: ["KnopoCore"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "KnopoCoreTests",
            dependencies: ["KnopoCore"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "KnopoTests",
            dependencies: ["Knopo", "KnopoCore"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
