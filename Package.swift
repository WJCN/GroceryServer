// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Grocery Server",
	platforms: [
		.macOS(.v13),
	],
	dependencies: [
		// 💧 A Swift Server Web Framework
		.package(url: "https://github.com/vapor/vapor",                  from: "4.0.0"),
		// 🗄 An ORM for SQL and NoSQL Databases
		.package(url: "https://github.com/vapor/fluent",                 from: "4.0.0"),
		// 🐘 Fluent Driver for Postgres
		.package(url: "https://github.com/vapor/fluent-postgres-driver", from: "2.0.0"),
		// 🔑 JSON Web Tokens
		.package(url: "https://github.com/vapor/jwt",                    from: "4.0.0"),
		// 📈 Grocery Data Transfer Objects
		.package(url: "https://github.com/WJCN/GroceryDTOs",             branch: "main"),
	],
	targets: [
		.executableTarget(
			name: "App",
			dependencies: [
				.product(name: "Vapor",                package: "Vapor"),
				.product(name: "Fluent",               package: "Fluent"),
				.product(name: "FluentPostgresDriver", package: "Fluent-Postgres-Driver"),
				.product(name: "JWT",                  package: "JWT"),
				.product(name: "GroceryDTOs",          package: "GroceryDTOs"),
			],
			swiftSettings: swiftSettings
		),
		.testTarget(
			name: "AppTests",
			dependencies: [
				.target(name:  "App"),
				.product(name: "XCTVapor", package: "Vapor"),
			],
			swiftSettings: swiftSettings
		),
	],
	swiftLanguageModes: [.v5]
)

var swiftSettings: [SwiftSetting] { [
	.enableUpcomingFeature("DisableOutwardActorInference"),
	.enableExperimentalFeature("StrictConcurrency"),
] }
