//
//  AuthenticationPayload.swift
//
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import Foundation
import JWT

struct AuthenticationPayload: JWTPayload {
	var expiration: ExpirationClaim
	var userID:     UUID

	func verify(using signer: JWTSigner) throws {
		try expiration.verifyNotExpired()
	}
}
