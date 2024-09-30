//
//  RegisterDTOExtensions.swift
//  Grocery Server
//
//  Created by William J. C. Nesbitt on 9/25/24.
//

import GroceryDTOs
import Vapor

extension RegisterResponseDTO: @retroactive Content {}
