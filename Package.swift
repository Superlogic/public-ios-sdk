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
            url: "https://github.com/Superlogic/SuperlogicWebViewKitBinary/releases/download/1.0.0/SuperlogicWebViewKit.xcframework.zip",
            checksum: "245973da17645d9215c4865ba60975db2f3b4cad80a29813ef0783d128f96623"
        ),
    ]
)
