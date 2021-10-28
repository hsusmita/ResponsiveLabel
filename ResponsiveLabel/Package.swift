// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ResponsiveLabel",
    products: [
        .library(
            name: "ResponsiveLabel",
            targets: ["ResponsiveLabel"])
    ],
    targets: [
        .target(
            name: "ResponsiveLabel",
            path: "ResponsiveLabel"
        )
    ]
)
