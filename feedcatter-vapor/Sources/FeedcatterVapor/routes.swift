import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get("ping") { req async in
        "pong"
    }

    try app.register(collection: FoodController())
}
