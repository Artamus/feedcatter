import Foundation
import SQLKit

protocol FoodRepository: Sendable {
    func create(_ food: CreatedFood, on db: any SQLDatabase) async throws -> Food
    func find(id: Int, on db: any SQLDatabase) async throws -> Food?
    func update(_ food: Food, on db: any SQLDatabase) async throws -> Food
    func delete(id: Int, on db: any SQLDatabase) async throws
    func all(on db: any SQLDatabase) async throws -> [Food]
}

final class DbFoodRepository: FoodRepository {
    let table = "foods"
    let allColumns = ["id", "created_at", "name", "state", "available_percentage"]

    func create(_ food: CreatedFood, on db: any SQLDatabase) async throws -> Food {
        let (state, availablePercentage) = dbStateOf(food.state)

        let insertedRow = try await db.insert(into: self.table)
            .columns(self.allColumns)
            .values(
                SQLLiteral.default, SQLLiteral.default, SQLBind(food.name), SQLBind(state),
                SQLBind(availablePercentage)
            )
            .returning("*")
            .first()

        if insertedRow == nil {
            throw FoodRepositoryError.insertFailed
        }

        let decodedRow = try insertedRow!.decode(model: FoodRow.self)
        return decodedRow.toFood()
    }

    func find(id: Int, on db: any SQLDatabase) async throws -> Food? {
        let maybeRow = try await db.select()
            .from(self.table)
            .columns(self.allColumns)
            .where("id", .equal, SQLBind(id))
            .first()

        let decodedRow = try maybeRow?.decode(model: FoodRow.self)
        return decodedRow?.toFood()
    }

    func update(_ food: Food, on db: any SQLDatabase) async throws -> Food {
        // Fetching this to keep parity between this and the ORM implementations for now.
        let _ = try await db.select()
            .from(self.table)
            .columns(self.allColumns)
            .where("id", .equal, SQLBind(food.id))
            .first()

        let (state, availablePercentage) = dbStateOf(food.state)
        try await db.update(self.table)
            .set("name", to: food.name)
            .set("state", to: state)
            .set("available_percentage", to: availablePercentage)
            .where("id", .equal, food.id)
            .run()

        return food
    }

    func delete(id: Int, on db: any SQLDatabase) async throws {
        // Fetching this to keep parity between this and the ORM implementations for now.
        let _ = try await db.select()
            .from(self.table)
            .columns(self.allColumns)
            .where("id", .equal, SQLBind(id))
            .first()

        try await db.delete(from: self.table)
            .where("id", .equal, id)
            .run()
    }

    func all(on db: any SQLDatabase) async throws -> [Food] {
        let rows = try await db.select()
            .from(self.table)
            .columns(self.allColumns)
            .where("state", .in, SQLBind([DbFoodState.available, DbFoodState.partiallyAvailable]))
            .all()

        let decodedRows = try rows.map { try $0.decode(model: FoodRow.self) }
        return decodedRows.map { $0.toFood() }
    }
}

enum FoodRepositoryError: Error {
    case insertFailed
    case notFound
}

private func dbStateOf(_ state: FoodState) -> (String, Double) {
    let dbState =
        switch state {
        case .available: "available"
        case .partiallyAvailable: "partially_available"
        case .eaten: "eaten"
        }

    let availablePercentage =
        switch state {
        case .available: 1.0
        case .partiallyAvailable(let percentage): percentage
        case .eaten: 0.0
        }

    return (dbState, availablePercentage)
}

struct FoodRow: Codable {
    var id: Int
    var createdAt: Date
    var name: String
    var state: DbFoodState
    var availablePercentage: Double

    func toFood() -> Food {
        let foodState =
            switch self.state {
            case .available: FoodState.available
            case .partiallyAvailable:
                FoodState.partiallyAvailable(percentage: self.availablePercentage)
            case .eaten: FoodState.eaten
            }

        return Food(id: self.id, createdAt: self.createdAt, name: self.name, state: foodState)
    }
}

enum DbFoodState: String, Codable {
    case available = "available"
    case partiallyAvailable = "partially_available"
    case eaten = "eaten"
}
