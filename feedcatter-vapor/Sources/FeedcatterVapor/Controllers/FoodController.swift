import Vapor

struct FoodController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let foods = routes.grouped("foods")

        foods.post(use: self.create)
        foods.get(use: self.list)
        foods.group(":foodID") { food in
            food.delete(use: self.delete)
        }
    }

    @Sendable
    func create(req: Request) async throws -> FoodDTO {
        let foodData = try req.content.decode(CreateFoodDTO.self)

        let food = Food(name: foodData.name)
        let createdFood = try await req.application.repositories.food.create(food, on: req.db)

        return FoodDTO(from: createdFood)
    }

    @Sendable
    func list(req: Request) async throws -> [FoodDTO] {
        let foods = try await req.application.repositories.food.all(on: req.db)

        return foods.map { FoodDTO(from: $0) }
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let foodId = req.parameters.get("foodID", as: Int.self) else {
            throw Abort(.badRequest)
        }

        try await req.application.repositories.food.delete(id: foodId, on: req.db)

        return .noContent
    }
}
