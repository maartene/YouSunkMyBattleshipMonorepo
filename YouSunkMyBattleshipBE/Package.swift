// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YouSunkMyBattleshipBE",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "YouSunkMyBattleshipBE",
            targets: ["YouSunkMyBattleshipBE"]
        ),
    ],
    dependencies: [
        .package(path: "../YouSunkMyBattleshipCommon"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "YouSunkMyBattleshipBE",
            dependencies: [
                "YouSunkMyBattleshipCommon",
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .testTarget(
            name: "YouSunkMyBattleshipBETests",
            dependencies: [
                "YouSunkMyBattleshipBE",
                .product(name: "VaporTesting", package: "vapor")
            ]
        ),
    ]
)
