//
//  GroceryCategory+Migration.swift
//  Grocery Server
//
//  Created by William J. C. Nesbitt on 9/27/24.
//

import Fluent
import GroceryDTOs
import Vapor

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.

final class GroceryCategory: Model, Validatable, @unchecked Sendable {
	static let schema = "grocery_categories"

	static let title  = FieldKey("title")
	static let color  = FieldKey("color")
	static let userID = FieldKey("user_id")

	@ID(key: .id)
	var id: UUID?

	@Field(key: title)
	var title: String

	@Field(key: color)
	var color: String

	@Parent(key: userID)
	var user: User

	@Children(for: \.$groceryCategory)
	var groceryItems: [GroceryItem]

	init() {}

	init(
		id:     UUID? = nil,
		title:  String,
		color:  String,
		userID: UUID
	) {
		self.id       = id
		self.title    = title
		self.color    = color
		self.$user.id = userID
	}

	convenience init(
		from groceryCategoryRequestDTO: GroceryCategoryRequestDTO,
		in   userID:                    UUID
	) {
		self.init(
			title:  groceryCategoryRequestDTO.title,
			color:  groceryCategoryRequestDTO.color,
			userID: userID
		)
	}

	static func validations(_ validations: inout Validations) {
		validations.add(
			ValidationKey(stringLiteral: title.description),
			as: String.self,
			is: !.empty,
			customFailureDescription: "Title cannot be empty."
		)
		validations.add(
			ValidationKey(stringLiteral: color.description),
			as: String.self,
			is: !.empty,
			customFailureDescription: "Color cannot be empty."
		)
	}
}

// MARK: -

final class GroceryCategoryMigration: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database
			.schema(GroceryCategory.schema)
			.id()
			.field(GroceryCategory.title,  .string, .required)
			.field(GroceryCategory.color,  .string, .required)
			.field(GroceryCategory.userID, .uuid,   .required, .references(User.schema, .id, onDelete: .cascade))
			.create()
	}

	func revert(on database: any Database) async throws {
		try await database
			.schema(GroceryCategory.schema)
			.delete()
	}
}
