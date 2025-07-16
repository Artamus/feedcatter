import Vapor

struct FoodController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let foods = routes.grouped("foods")

        foods.post(use: self.create)
        foods.get(use: self.list)
        foods.group(":foodID") { food in
            food.delete(use: self.delete)
        }

        foods.get("suggestion", use: self.getFoodSuggestion)
        foods.post("meal", use: self.createMeal)
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

    @Sendable
    func getFoodSuggestion(req: Request) async throws -> FoodDTO {
        let foods = try await req.application.repositories.food.all(on: req.db)
        if foods.isEmpty {
            throw Abort(.notFound, reason: "no foods found")
        }

        let openedFoods = foods.filter { food in
            switch food.state {
            case .partiallyAvailable: return true
            default: return false
            }
        }

        if !openedFoods.isEmpty {
            return FoodDTO(from: openedFoods.first!)
        }

        return FoodDTO(from: foods.first!)
    }

    @Sendable
    func createMeal(req: Request) async throws -> FoodDTO {
        let mealData = try req.content.decode(CreateMealDTO.self)

        guard
            let food = try await req.application.repositories.food.find(
                id: mealData.food, on: req.db)
        else {
            throw Abort(.notFound, reason: "food \(mealData.food) not found")
        }

        do {
            try food.consume(percentage: mealData.percentage)
        } catch FoodError.noneRemaining {
            throw Abort(.preconditionFailed, reason: "unable to consume food that is already eaten")
        }

        let updatedFood = try await req.application.repositories.food.update(food, on: req.db)

        return FoodDTO(from: updatedFood)
    }
}
