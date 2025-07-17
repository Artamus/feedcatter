import GRPCCore
import GRPCNIOTransportHTTP2

extension Feedcatter {
    func runServer() async throws {
        let feedcatter = FeedcatterService()
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
    }
}
