//
//  JWTAuthentication.swift
//  Grocery Server
//
//  Created by William J. C. Nesbitt on 9/29/24.
//

import Vapor

struct JWTAuthenticator: AsyncRequestAuthenticator {
	func authenticate(request: Vapor.Request) async throws {
		try request.jwt.verify(as: AuthenticationPayload.self)
	}
}
