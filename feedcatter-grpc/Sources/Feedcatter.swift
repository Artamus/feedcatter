@main
struct Feedcatter {
  static func main() async throws {
    try await Feedcatter().runServer()
  }
}
