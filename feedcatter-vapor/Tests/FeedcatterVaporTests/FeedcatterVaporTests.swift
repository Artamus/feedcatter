import Fluent
import FluentSQLiteDriver
import Testing
import VaporTesting

@testable import FeedcatterVapor

@Suite("App Tests with DB", .serialized)
struct FeedcatterVaporTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("pings the server")
    func ping() async throws {
        try await withApp { app in
            try await app.testing().test(
                .GET, "ping",
                afterResponse: { res async in
                    #expect(res.status == .ok)
                    #expect(res.body.string == "pong")
                })
        }
    }

    @Test("creates a food")
    func createFood() async throws {
        try await withApp { app in
            let createFoodDto = CreateFoodDTO(name: "Ookeanikala")
            try await app.testing().test(
                .POST, "foods",
                beforeRequest: { req in
                    try req.content.encode(createFoodDto)
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let models = try await FoodModel.query(on: app.db).all()
                    #expect(models.map({ $0.name }) == [createFoodDto.name])
                })
        }
    }

    @Test("deletes a food")
    func deleteFood() async throws {
        try await withApp { app in
            let foodModel = FoodModel(
                name: "Ookeanikala", state: DbFoodState.available, availablePercentage: 1.0)
            try await foodModel.save(on: app.db)

            try await app.testing().test(
                .DELETE, "foods/\(foodModel.id!)",
                afterResponse: { res async throws in
                    #expect(res.status == .noContent)
                    let models = try await FoodModel.query(on: app.db).all()
                    #expect(models.count == 0)
                })
        }
    }

    @Test("lists foods")
    func listsFoods() async throws {
        try await withApp { app in
            let foodModel = FoodModel(
                name: "Ookeanikala", state: DbFoodState.available, availablePercentage: 1.0)
            try await foodModel.save(on: app.db)
            let foodModelTwo = FoodModel(
                name: "Kana", state: DbFoodState.available, availablePercentage: 1.0)
            try await foodModelTwo.save(on: app.db)

            try await app.testing().test(
                .GET, "foods",
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let models = try await FoodModel.query(on: app.db).all()
                    #expect(models.map { $0.name } == ["Ookeanikala", "Kana"])
                })
        }
    }

    @Test("fails creating a meal from a food that doesn't exist")
    func failsNonExistentFood() async throws {
        try await withApp { app in
            let createMealDto = CreateMealDTO(food: 420, percentage: 1.0)
            try await app.testing().test(
                .POST, "foods/meal",
                beforeRequest: { req in
                    try req.content.encode(createMealDto)
                },
                afterResponse: { res async throws in
                    #expect(res.status == .notFound)
                })
        }
    }

    @Test("fails creating a meal from an eaten food")
    func failsEatenFood() async throws {
        try await withApp { app in
            let foodModel = FoodModel(
                name: "Ookeanikala", state: DbFoodState.eaten, availablePercentage: 0.0)
            try await foodModel.save(on: app.db)

            let createMealDto = CreateMealDTO(food: foodModel.id!, percentage: 0.5)
            try await app.testing().test(
                .POST, "foods/meal",
                beforeRequest: { req in
                    try req.content.encode(createMealDto)
                },
                afterResponse: { res async throws in
                    #expect(res.status == .preconditionFailed)
                    let updatedFoodModel = try await FoodModel.find(foodModel.id!, on: app.db)
                    #expect(updatedFoodModel?.state == foodModel.state)
                    #expect(updatedFoodModel?.availablePercentage == foodModel.availablePercentage)
                })
        }
    }

    @Test("creates a meal from an available food")
    func createsMealFromPartial() async throws {
        try await withApp { app in
            let foodModel = FoodModel(
                name: "Ookeanikala", state: DbFoodState.available, availablePercentage: 1.0)
            try await foodModel.save(on: app.db)

            let createMealDto = CreateMealDTO(food: foodModel.id!, percentage: 0.5)
            try await app.testing().test(
                .POST, "foods/meal",
                beforeRequest: { req in
                    try req.content.encode(createMealDto)
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let responseDto = try res.content.decode(FoodDTO.self)
                    #expect(
                        responseDto
                            == FoodDTO(
                                id: foodModel.id!, createdAt: foodModel.createdAt!,
                                name: "Ookeanikala",
                                state: FoodDTOState.partiallyAvailable(percentage: 0.5)))
                })
        }
    }
}
