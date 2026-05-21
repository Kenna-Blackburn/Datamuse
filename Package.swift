//
//  Package.swift
//  Datamuse
//
//  Created by Kenna Blackburn on 5/20/26.
//

// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Datamuse",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "Datamuse",
            targets: ["Datamuse"],
        ),
    ],
    targets: [
        .target(
            name: "Datamuse",
        ),
    ],
)
