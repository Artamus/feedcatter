import Fluent

struct CreateFood: AsyncMigration {
    func prepare(on database: any Database) async throws {

        let foodState = try await database.enum("food_state")
            .case("available")
            .case("partiallyAvailable")
            .case("eaten")
            .create()

        try await database.schema("foods")
            .field("id", .int, .identifier(auto: true))
            .field("created_at", .datetime, .required)
            .field("name", .string, .required)
            .field("state", foodState, .required)
            .field("available_percentage", .double, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("foods").delete()
    }
}
