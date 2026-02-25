// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContractTest",
    platforms: [
        .macOS(.v15),
    ],
    dependencies: [
        .package(url: "https://github.com/Local-Connectivity-Lab/lcl-websocket.git", from: "1.0.0"),
        .package(path: "../../../YouSunkMyBattleshipCommon"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "ContractTest",
            dependencies: [
                .product(name: "LCLWebSocket", package: "lcl-websocket"),
                .product(name: "YouSunkMyBattleshipCommon", package: "YouSunkMyBattleshipCommon"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
