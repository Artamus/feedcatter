import Foundation
import Testing

@testable import FeedcatterVapor

@Suite("FoodSuggester", .serialized)
struct FoodSuggesterTests {
    @Test("suggests nothing if the choice is empty")
    func emptyChoice() async throws {
        let suggestion = suggestFood(choice: [])

        #expect(suggestion == nil)
    }

    @Test("suggests a partially eaten food over a closed one")
    func prefersPartiallyEaten() async throws {
        let availableFood = Food(
            id: 1, createdAt: Date(timeIntervalSince1970: TimeInterval(1000)),
            name: "Ookeanikala", state: .available)
        let partiallyEatenFood = Food(
            id: 2, createdAt: Date(timeIntervalSince1970: TimeInterval(5000)),
            name: "Ookeanikala", state: .partiallyAvailable(percentage: 0.5))

        let suggestion = suggestFood(choice: [availableFood, partiallyEatenFood])

        #expect(suggestion == partiallyEatenFood)
    }

    @Test("prefers the most abundant closed food")
    func prefersMostAbundant() async throws {
        let chicken = Food(
            id: 1, createdAt: Date(timeIntervalSince1970: TimeInterval(1000)),
            name: "Kana", state: .available)
        let olderOceanFish = Food(
            id: 2, createdAt: Date(timeIntervalSince1970: TimeInterval(2000)),
            name: "Ookeanikala", state: .available)
        let newerOceanFish = Food(
            id: 3, createdAt: Date(timeIntervalSince1970: TimeInterval(5000)),
            name: "Ookeanikala", state: .available)

        let suggestion = suggestFood(choice: [chicken, olderOceanFish, newerOceanFish])

        #expect(suggestion == olderOceanFish)
    }

    @Test("prefers the oldest item of the most abundant food")
    func prefersOldestMostAbundant() async throws {
        let chicken = Food(
            id: 1, createdAt: Date(timeIntervalSince1970: TimeInterval(1000)),
            name: "Kana", state: .available)
        let olderOceanFish = Food(
            id: 2, createdAt: Date(timeIntervalSince1970: TimeInterval(2000)),
            name: "Ookeanikala", state: .available)
        let newerOceanFish = Food(
            id: 3, createdAt: Date(timeIntervalSince1970: TimeInterval(5000)),
            name: "Ookeanikala", state: .available)

        let suggestion = suggestFood(choice: [chicken, newerOceanFish, olderOceanFish])  // Older ocean fish goes last to ensure we don't just check based on order.

        #expect(suggestion == olderOceanFish)
    }
}
