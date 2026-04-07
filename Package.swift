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
            url: "https://github.com/Superlogic/public-ios-sdk/releases/download/2.0.11/SuperlogicWebViewKit.xcframework.zip",
            checksum: "7cd5780375e649813c5bb3c7e20818b33cff31b0d229fc7291085072083d2f73"
        ),
    ]
)
