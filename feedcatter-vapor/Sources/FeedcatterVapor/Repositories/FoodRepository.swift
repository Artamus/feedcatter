import Fluent
import Vapor

protocol FoodRepository: Sendable {
    func create(_ food: Food, on db: any Database) async throws -> Food
    func find(id: Int, on db: any Database) async throws -> Food?
    func update(_ food: Food, on db: any Database) async throws -> Food
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

    func update(_ food: Food, on db: any Database) async throws -> Food {
        guard let existingFoodModel = try await FoodModel.find(food.id, on: db) else {
            throw FoodRepositoryError.notFound
        }

        existingFoodModel.apply(food)

        try await existingFoodModel.update(on: db)

        return food
    }

    func delete(id: Int, on db: any Database) async throws {
        let foodModel = try await FoodModel.find(id, on: db)
        guard let model = foodModel else {
            throw FoodRepositoryError.notFound
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

enum FoodRepositoryError: Error {
    case notFound
}
