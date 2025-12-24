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
            url: "https://github.com/Superlogic/SuperlogicWebViewKitBinary/releases/download/1.2.0/SuperlogicWebViewKit.xcframework.zip",
            checksum: "73395fe094d90189a8cfe226385c8520b13df922be5ca3b73d558a27092cce69"
        ),
    ]
)
