// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "comet",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.97.0")
    ],
    targets: [
        .executableTarget(
            name: "comet",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            path: "src"
        ),
    ]
)
