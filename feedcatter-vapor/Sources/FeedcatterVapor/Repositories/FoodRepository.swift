import Fluent
import Vapor

protocol FoodRepository: Sendable {
    func create(_ food: Food, on db: any Database) async throws -> Food
    func find(id: Int, on db: any Database) async throws -> Food?
    func delete(id: Int, on db: any Database) async throws
    func all(on db: any Database) async throws -> [Food]
}

final class FluentFoodRepository: FoodRepository {
    func create(_ food: Food, on db: any Database) async throws -> Food {
        let foodModel = FoodModel(from: food)
        try await foodModel.save(on: db)
        return try foodModel.toDomain()
    }

    func find(id: Int, on db: any Database) async throws -> Food? {
        let foodModel = try await FoodModel.find(id, on: db)
        return try foodModel?.toDomain()
    }

    func delete(id: Int, on db: any Database) async throws {
        let foodModel = try await FoodModel.find(id, on: db)
        guard let model = foodModel else {
            throw Abort(.notFound, reason: "Food with ID \(id) not found for deletion.")
        }
        try await model.delete(on: db)
    }

    func all(on db: any Database) async throws -> [Food] {
        let foodModels = try await FoodModel.query(on: db).filter(
            \.$state ~~ [.available, .partiallyAvailable]
        ).all()
        return try foodModels.map { try $0.toDomain() }
    }
}
