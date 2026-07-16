// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "external_app_launcher",
    platforms:[
        .iOS("13.0")
    ],
    products:[
        .library(name: "external-app-launcher", targets: ["external_app_launcher"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets:[
        .target(
            name: "external_app_launcher",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include")
            ]
        )
    ]
)
