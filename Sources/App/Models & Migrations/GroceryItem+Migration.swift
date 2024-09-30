//
//  GroceryItem+Migration.swift
//  Grocery Server
//
//  Created by William J. C. Nesbitt on 9/29/24.
//

import Fluent
import GroceryDTOs
import Vapor

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.

final class GroceryItem: Model, Validatable, @unchecked Sendable {
	static let schema = "grocery_items"

	static let title             = FieldKey("title")
	static let price             = FieldKey("price")
	static let quantity          = FieldKey("quantity")
	static let groceryCategoryID = FieldKey("grocery_category_id")

	@ID(key: .id)
	var id: UUID?

	@Field(key: title)
	var title: String

	@Field(key: price)
	var price: Double

	@Field(key: quantity)
	var quantity: Int

	@Parent(key: groceryCategoryID)
	var groceryCategory: GroceryCategory

	init() {}

	init(
		id:                UUID? = nil,
		title:             String,
		price:             Double,
		quantity:          Int,
		groceryCategoryID: UUID
	) {
		self.id                  = id
		self.title               = title
		self.price               = price
		self.quantity            = quantity
		self.$groceryCategory.id = groceryCategoryID
	}

	convenience init(
		from groceryItemRequestDTO: GroceryItemRequestDTO,
		in   groceryCategoryID:     UUID
	) {
		self.init(
			title:    groceryItemRequestDTO.title,
			price:    groceryItemRequestDTO.price,
			quantity: groceryItemRequestDTO.quantity,
			groceryCategoryID: groceryCategoryID
		)
	}

	static func validations(_ validations: inout Validations) {
		validations.add(
			ValidationKey(stringLiteral: title.description),
			as: String.self,
			is: !.empty,
			customFailureDescription: "Title cannot be empty."
		)
	}
}

// MARK: -

final class GroceryItemMigration: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database
			.schema(GroceryItem.schema)
			.id()
			.field(GroceryItem.title,             .string, .required)
			.field(GroceryItem.price,             .double, .required)
			.field(GroceryItem.quantity,          .int,    .required)
			.field(GroceryItem.groceryCategoryID, .uuid,   .required, .references(GroceryCategory.schema, .id, onDelete: .cascade))
			.create()
	}

	func revert(on database: Database) async throws {
		try await database
			.schema(GroceryItem.schema)
			.delete()
	}
}
