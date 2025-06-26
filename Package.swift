// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "NSKJSON",
    platforms: [
        .macOS(.v11_0),
        .iOS(.v15),
        .tvOS(.v12),
        .watchOS(.v4),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "NSKJSON",
                 targets: ["NSKJSON"]),
        .library(name: "NSKJSONDynamic",
                 type: .dynamic,
                 targets: ["NSKJSON"]),
    ],
    targets: [
        .target(name: "NSKJSON",
                path: "Source/Swift"),
    ]
)
