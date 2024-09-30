//
//  GroceryItemDTOExtensions.swift
//  Grocery Server
//
//  Created by William J. C. Nesbitt on 9/29/24.
//

import GroceryDTOs
import Vapor

extension GroceryItemResponseDTO: @retroactive Content {
	init(from groceryItem: GroceryItem) throws {
		try self.init(
			id:       groceryItem.requireID(),
			title:    groceryItem.title,
			price:    groceryItem.price,
			quantity: groceryItem.quantity
		)
	}
}
