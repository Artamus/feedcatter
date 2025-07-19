import GRPCCore
import GRPCNIOTransportHTTP2
import Logging
import PostgresKit

extension Feedcatter {
    func runServer() async throws {
        let configuration = SQLPostgresConfiguration(
            hostname: "localhost",
            username: "postgres",
            password: "postgres",
            database: "feedcatter",
            tls: .disable
        )
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let pools = EventLoopGroupConnectionPool(
            source: PostgresConnectionSource(sqlConfiguration: configuration),
            on: eventLoopGroup
        )

        let foodRepository = DbFoodRepository()
        let feedcatter = FeedcatterService(
            foodRepository: foodRepository,
            dbPool: pools.database(logger: Logger(label: "postgres")))

        let server = GRPCServer(
            transport: .http2NIOPosix(
                address: .ipv4(host: "127.0.0.1", port: 31415),
                transportSecurity: .plaintext
            ),
            services: [feedcatter]
        )

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await server.serve()
            }

            if let address = try await server.listeningAddress {
                print("Feedcatter server listening on \(address)")
            }
        }

        try! await pools.shutdownAsync()
        try! await eventLoopGroup.shutdownGracefully()
    }
}
