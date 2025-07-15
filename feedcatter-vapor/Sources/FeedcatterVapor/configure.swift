import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(
        DatabaseConfigurationFactory.postgres(
            configuration: .init(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))
                    ?? SQLPostgresConfiguration.ianaPortNumber,
                username: Environment.get("DATABASE_USERNAME") ?? "postgres",
                password: Environment.get("DATABASE_PASSWORD") ?? "postgres",
                database: Environment.get("DATABASE_NAME") ?? "feedcatter",
                // tls: .prefer(try .init(configuration: .clientDefault))
                tls: .disable
            )
        ), as: .psql)

    app.migrations.add(CreateFood())

    app.registerFoodRepository { application in
        return FluentFoodRepository()
    }

    // register routes
    try routes(app)
}

extension Application {
    struct Repositories {
        let application: Application

        struct FoodRepositoryKey: StorageKey {
            typealias Value = any FoodRepository & Sendable
        }

        var food: any FoodRepository & Sendable {
            if let existing = application.storage[FoodRepositoryKey.self] {
                return existing
            } else {
                fatalError(
                    "FoodRepository not registered. Call app.registerFoodRepository() in configure.swift"
                )
            }
        }
    }

    var repositories: Repositories {
        .init(application: self)
    }

    func registerFoodRepository(make: @escaping (Application) -> (any FoodRepository & Sendable)) {
        self.storage[Repositories.FoodRepositoryKey.self] = make(self)
    }
}
