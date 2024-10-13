#warning("The PostgreSQL Transport Layer Security (TLS) is disabled.")

import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ application: Application) async throws {
	// uncomment to serve files from /Public folder
	// application.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	application
		.databases
		.use(
			.postgres(
				configuration: SQLPostgresConfiguration(
					hostname: Environment.get("DATABASE_HOSTNAME") ?? "",
					port:     Environment.get("DATABASE_PORT").flatMap(Int.init) ?? SQLPostgresConfiguration.ianaPortNumber,
					username: Environment.get("DATABASE_USERNAME") ?? "",
					password: Environment.get("DATABASE_PASSWORD") ?? "",
					database: Environment.get("DATABASE")          ?? "",
					tls:     .disable
				)
			),
			as: .psql
		)

	// add migrations
	application.migrations.addAll()

	// automatically run migrations on startup
	try await application.autoMigrate()

	application.jwt.signers.use(.hs512(key: Environment.get("JWT_SIGNING_KEY") ?? ""))

	// register routes
	try routes(application)
}
