//
//  GroceryCategoryDTOExtensions.swift
//  Grocery Server
//
//  Created by William J. C. Nesbitt on 9/28/24.
//

import GroceryDTOs
import Vapor

extension GroceryCategoryResponseDTO: @retroactive Content {
	init(from groceryCategory: GroceryCategory) throws {
		try self.init(
			id:           groceryCategory.requireID(),
			title:        groceryCategory.title,
			color:        groceryCategory.color,
			groceryItems: groceryCategory.$groceryItems.value?.map(GroceryItemResponseDTO.init) ?? []
		)
	}
}
