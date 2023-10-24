// swift-tools-version: 5.8

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
            url: "https://github.com/Boilertalk/secp256k1.swift.git",
            from: "0.1.7"
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
                .product(name: "secp256k1", package: "secp256k1.swift")
            ]
        ),
        .testTarget(
            name: "MetadataHDWalletKitTests",
            dependencies: ["MetadataHDWalletKit"]
        )
    ]
)
