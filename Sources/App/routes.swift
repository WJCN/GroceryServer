import Vapor

func routes(_ application: Application) throws {
	try application.register(collection: GroceryController())
	try application.register(collection: UserRoutes())
}
