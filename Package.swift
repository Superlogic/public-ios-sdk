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
            url: "https://github.com/Superlogic/SuperlogicWebViewKitBinary/releases/download/2.0.0/SuperlogicWebViewKit.xcframework.zip",
            checksum: "90b1da1317800a37b7e5aa20cc6ae1f101c6741ef8d56ce457c473fbf62b5249"
        ),
    ]
)
