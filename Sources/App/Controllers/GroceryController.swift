//
//  GroceryController.swift
//  Grocery Server
//
//  Created by William J. C. Nesbitt on 9/28/24.
//

import Fluent
import GroceryDTOs
import Vapor

struct GroceryController: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let protectedAPI = routes
			.grouped(JWTAuthenticator())
			.grouped("api")

		let usersUserID = protectedAPI.grouped("users", ":userID")

#if false
		usersUserID.get("grocery-categories-with-items", use: getGroceryCategoriesWithItems)
#endif

		let groceryCategories = usersUserID.grouped("grocery-categories")
		groceryCategories.get (use: getGroceryCategories)
		groceryCategories.post(use: saveGroceryCategory)

		let groceryCategoryID = groceryCategories.grouped(":groceryCategoryID")
		groceryCategoryID.delete(use: deleteGroceryCategory)

		let groceryItems = groceryCategoryID.grouped("grocery-items")
		groceryItems.get (use: getGroceryItems)
		groceryItems.post(use: saveGroceryItem)

		let groceryItemID = groceryItems.grouped(":groceryItemID")
		groceryItemID.delete(use: deleteGroceryItem)
	}

	@Sendable
	private func deleteGroceryCategory(request: Request) async throws -> GroceryCategoryResponseDTO {
		guard let userID            = request.parameters.get("userID",            as: UUID.self),
			  let groceryCategoryID = request.parameters.get("groceryCategoryID", as: UUID.self)
		else {
			throw Abort(.badRequest)
		}

		// Check if this/these database record(s) exist(s).
		guard let _               = try await User           .find(userID,            on: request.db),
			  let groceryCategory = try await GroceryCategory.find(groceryCategoryID, on: request.db)
		else {
			throw Abort(.notFound)
		}

		try await groceryCategory.delete(on: request.db)
		return try GroceryCategoryResponseDTO(from: groceryCategory)
	}

	@Sendable
	private func deleteGroceryItem(request: Request) async throws -> GroceryItemResponseDTO {
		guard let userID            = request.parameters.get("userID",            as: UUID.self),
			  let groceryCategoryID = request.parameters.get("groceryCategoryID", as: UUID.self),
			  let groceryItemID     = request.parameters.get("groceryItemID",     as: UUID.self)
		else {
			throw Abort(.badRequest)
		}

		// Check if this/these database record(s) exist(s).
		guard let _           = try await User           .find(userID,            on: request.db),
			  let _           = try await GroceryCategory.find(groceryCategoryID, on: request.db),
			  let groceryItem = try await GroceryItem    .find(groceryItemID,     on: request.db)
		else {
			throw Abort(.notFound)
		}

		try await groceryItem.delete(on: request.db)
		return try GroceryItemResponseDTO(from: groceryItem)
	}

	@Sendable
	private func getGroceryCategories(request: Request) async throws -> [GroceryCategoryResponseDTO] {
		guard let userID = request.parameters.get("userID", as: UUID.self)
		else {
			throw Abort(.badRequest)
		}

		// Check if this/these database record(s) exist(s).
		guard let _ = try await User.find(userID, on: request.db)
		else {
			throw Abort(.notFound)
		}

		return try await GroceryCategory
			.query(on: request.db)
			.filter(\.$user.$id == userID)
			.all()
			.map(GroceryCategoryResponseDTO.init)
	}

	@Sendable
	private func getGroceryCategoriesWithItems(request: Request) async throws -> [GroceryCategoryResponseDTO] {
		guard let userID = request.parameters.get("userID", as: UUID.self)
		else {
			throw Abort(.badRequest)
		}

		// Check if this/these database record(s) exist(s).
		guard let _ = try await User.find(userID, on: request.db)
		else {
			throw Abort(.notFound)
		}

		return try await GroceryCategory
			.query(on: request.db)
			.filter(\.$user.$id == userID)
			.with(\.$groceryItems)
			.all()
			.map(GroceryCategoryResponseDTO.init)
	}

	@Sendable
	private func getGroceryItems(request: Request) async throws -> [GroceryItemResponseDTO] {
		guard let userID            = request.parameters.get("userID",            as: UUID.self),
			  let groceryCategoryID = request.parameters.get("groceryCategoryID", as: UUID.self)
		else {
			throw Abort(.badRequest)
		}

		// Check if this/these database record(s) exist(s).
		guard let _ = try await User           .find(userID,            on: request.db),
			  let _ = try await GroceryCategory.find(groceryCategoryID, on: request.db)
		else {
			throw Abort(.notFound)
		}

		return try await GroceryItem
			.query(on: request.db)
			.filter(\.$groceryCategory.$id == groceryCategoryID)
			.all()
			.map(GroceryItemResponseDTO.init)
	}

	@Sendable
	private func saveGroceryCategory(request: Request) async throws -> GroceryCategoryResponseDTO {
		guard let userID = request.parameters.get("userID", as: UUID.self)
		else {
			throw Abort(.badRequest)
		}

		// Check if this/these database record(s) exist(s).
		guard let _ = try await User.find(userID, on: request.db) else {
			throw Abort(.notFound)
		}

		try GroceryCategory.validate(content: request)
		let groceryCategoryRequestDTO = try request.content.decode(GroceryCategoryRequestDTO.self)
		let groceryCategory = GroceryCategory(from: groceryCategoryRequestDTO, in: userID)
		try await groceryCategory.save(on: request.db)
		return try GroceryCategoryResponseDTO(from: groceryCategory)
	}

	@Sendable
	private func saveGroceryItem(request: Request) async throws -> GroceryItemResponseDTO {
		guard let userID            = request.parameters.get("userID",            as: UUID.self),
			  let groceryCategoryID = request.parameters.get("groceryCategoryID", as: UUID.self)
		else {
			throw Abort(.badRequest)
		}

		// Check if this/these database record(s) exist(s).
		guard let _ = try await User           .find(userID,            on: request.db),
			  let _ = try await GroceryCategory.find(groceryCategoryID, on: request.db)
		else {
			throw Abort(.notFound)
		}

		try GroceryItem.validate(content: request)
		let groceryItemRequestDTO = try request.content.decode(GroceryItemRequestDTO.self)
		let groceryItem = GroceryItem(from: groceryItemRequestDTO, in: groceryCategoryID)
		try await groceryItem.save(on: request.db)
		return try GroceryItemResponseDTO(from: groceryItem)
	}
}
