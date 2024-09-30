//
//  MigrationsExtension.swift
//  Grocery Server
//
//  Created by William J. C. Nesbitt on 9/27/24.
//

import Fluent

extension Migrations {
	func addAll() {
		add(UsersMigration())
		add(GroceryCategoryMigration())
		add(GroceryItemMigration())
	}
}
