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
            url: "https://github.com/Superlogic/SuperlogicWebViewKitBinary/releases/download/1.1.0/SuperlogicWebViewKit.xcframework.zip",
            checksum: "2b0ecbf1de072fb7f1ccfdc61d89d2c19c0375f003f96c0420b231657ebd4ea3"
        ),
    ]
)
