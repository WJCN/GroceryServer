//
//  UsersController.swift
//
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import Fluent
import GroceryDTOs
import JWT
import Vapor

struct UserRoutes: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let api = routes.grouped("api")
		api.post("register", use: register)
		api.post("sign-in",  use: signIn)
	}

	// MARK: - Private Functions

	@Sendable
	private func register(request: Request) async throws -> RegisterResponseDTO {
		try User.validate(content: request)
		let user = try request.content.decode(User.self)

		guard try await User
			.query(on: request.db)
			.filter(\.$username == user.username)
			.count() == 0
		else {
			throw Abort(.conflict, reason: "Username is already taken.")
		}

		user.password = try await request.password.async.hash(user.password)
		try await user.save(on: request.db)
		return RegisterResponseDTO(error: false)
	}

	@Sendable
	private func signIn(request: Request) async throws -> SignInResponseDTO {
		let loginUser = try request.content.decode(User.self)

		let existingUsers = try await User
			.query(on: request.db)
			.filter(\.$username == loginUser.username)
			.all()

		guard (0 ... 1).contains(existingUsers.count)
		else {
			throw Abort(.internalServerError)
		}

		guard let existingUser = existingUsers.first
		else {
			throw Abort(.notFound)
		}

		guard try await request.password.async.verify(
			loginUser.password,
			created: existingUser.password)
		else {
			throw Abort(.unauthorized)
		}

		let authenticationPayload = try AuthenticationPayload(
			expiration: ExpirationClaim(value: .distantFuture),
			userID:     existingUser.requireID()
		)

		return try SignInResponseDTO(
			error:  false,
			token:  request.jwt.sign(authenticationPayload),
			userID: existingUser.requireID()
		)
	}
}
