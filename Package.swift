// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "MetadataHDWalletKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "MetadataHDWalletKit",
            targets: ["MetadataHDWalletKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/21-DOT-DEV/swift-secp256k1.git",
            exact: "0.17.0"
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            from: "1.8.0"
        )
    ],
    targets: [
        .target(
            name: "MetadataHDWalletKit",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "secp256k1", package: "swift-secp256k1")
            ]
        ),
        .testTarget(
            name: "MetadataHDWalletKitTests",
            dependencies: ["MetadataHDWalletKit"]
        )
    ]
)
