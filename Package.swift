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
            url: "https://github.com/Superlogic/public-ios-sdk/releases/download/2.0.12/SuperlogicWebViewKit.xcframework.zip",
            checksum: "8adeb9c0b2790f1bf0c2ca5b6df045c22511e49832e11166afc0ae3f246acaca"
        ),
    ]
)
