// swift-tools-version: 6.0
// Binary distribution of SuperlogicWebViewKit

import PackageDescription

let package = Package(
    name: "SuperlogicWebViewKit",
    platforms: [
        .iOS(.v17)
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
            url: "https://github.com/Superlogic/public-ios-sdk/releases/download/2.0.1/SuperlogicWebViewKit.xcframework.zip",
            checksum: "17fa94b07046140d8e474c42ca52799e0d9531d637b743e5590caeee54550d8e"
        ),
    ]
)
