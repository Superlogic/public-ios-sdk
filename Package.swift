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
            url: "https://github.com/Superlogic/public-ios-sdk/releases/download/2.0.5/SuperlogicWebViewKit.xcframework.zip",
            checksum: "b10a78fef43787358162c40c5c3cf7220b05d4038d145aec5504f4765742fd0b"
        ),
    ]
)
