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
            url: "https://github.com/Superlogic/public-ios-sdk/releases/download/2.2.0/SuperlogicWebViewKit.xcframework.zip",
            checksum: "3c66a3cabe4ef2b21b48ec4c7ac0aeb34b6cec9a08a81e22ed575a7be21d3847"
        ),
    ]
)
