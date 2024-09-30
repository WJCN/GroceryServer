// swift-tools-version:5.10
import PackageDescription

let package = Package(
	name: "Grocery Server",
	platforms: [
		.macOS(.v13)
	],
	dependencies: [
		// 💧 A server-side Swift web framework.
		.package(url: "https://github.com/vapor/vapor.git",                  from: "4.99.3"),
		// 🗄 An ORM for SQL and NoSQL databases.
		.package(url: "https://github.com/vapor/fluent.git",                 from: "4.9.0"),
		// 🐘 Fluent driver for Postgres.
		.package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
		// 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors.
		.package(url: "https://github.com/apple/swift-nio.git",              from: "2.65.0"),
		// 🔑 JSON Web Tokens
		.package(url: "https://github.com/vapor/jwt.git",                    from: "4.0.0"),
		//
		.package(url: "https://github.com/WJCN/GroceryDTOs.git",             branch: "main")
	],
	targets: [
		.executableTarget(
			name: "App",
			dependencies: [
				.product(name: "Vapor",                package: "Vapor"),
				.product(name: "Fluent",               package: "Fluent"),
				.product(name: "FluentPostgresDriver", package: "Fluent-Postgres-Driver"),
				.product(name: "NIOCore",              package: "Swift-NIO"),
				.product(name: "NIOPosix",             package: "Swift-NIO"),
				.product(name: "JWT",                  package: "JWT"),
				.product(name: "GroceryDTOs",          package: "GroceryDTOs")
			],
			swiftSettings: swiftSettings
		),
		.testTarget(
			name: "AppTests",
			dependencies: [
				.target(name: "App"),
				.product(name: "XCTVapor", package: "Vapor"),
			],
			swiftSettings: swiftSettings
		)
	]
)

var swiftSettings: [SwiftSetting] { [
	.enableUpcomingFeature("DisableOutwardActorInference"),
	.enableExperimentalFeature("StrictConcurrency"),
] }
