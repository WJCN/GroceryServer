//
//  User+Migration.swift
//
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import Fluent
import Vapor

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.

final class User: Model, Validatable, @unchecked Sendable {
	static let schema = "users"

	static let username = FieldKey("username")
	static let password = FieldKey("password")

	@ID(key: .id)
	var id: UUID?

	@Field(key: username)
	var username: String

	@Field(key: password)
	var password: String

	@Children(for: \.$user)
	var groceryCategories: [GroceryCategory]

	init() {}

	init(
		id:       UUID? = nil,
		username: String,
		password: String
	) {
		self.id       = id
		self.username = username
		self.password = password
	}

	static func validations(_ validations: inout Validations) {
		validations.add(
			ValidationKey(stringLiteral: username.description),
			as: String.self,
			is: !.empty,
			customFailureDescription: "Username cannot be empty.")
		validations.add(
			ValidationKey(stringLiteral: password.description),
			as: String.self,
			is: !.empty,
			customFailureDescription: "Password cannot be empty.")
		validations.add(
			ValidationKey(stringLiteral: password.description),
			as: String.self,
			is: .count(5 ... 10),
			customFailureDescription: "Password must be between 5 and 10 characters.")
	}
}

// MARK: -

struct UsersMigration: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database
			.schema(User.schema)
			.id()
			.field(User.username, .string, .required)
			.field(User.password, .string, .required)
			.unique(on: User.username)
			.create()
	}

	func revert(on database: any Database) async throws {
		try await database
			.schema(User.schema)
			.delete()
	}
}
