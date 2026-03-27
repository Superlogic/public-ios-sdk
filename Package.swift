// swift-tools-version: 6.0
// Binary distribution of SuperlogicWebViewKit

import PackageDescription

let package = Package(
    name: "SuperlogicWebViewKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SuperlogicWebViewKit",
            targets: ["SuperlogicWebViewKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SuperlogicWebViewKit",
            url: "https://github.com/Superlogic/public-ios-sdk/releases/download/2.0.8/SuperlogicWebViewKit.xcframework.zip",
            checksum: "0d8537e86ede405739fae8f6d6e55e93519ca26e208ade82f2408eff3f804e69"
        ),
    ]
)
