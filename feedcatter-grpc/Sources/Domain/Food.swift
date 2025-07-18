import Foundation

class Food: Equatable {
    var id: Int
    var createdAt: Date
    var name: String
    var state: FoodState

    init(id: Int, createdAt: Date, name: String, state: FoodState) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.state = state
    }

    func consume(percentage: Double) throws {
        switch self.state {
        case .available:
            if percentage >= 1.0 {
                self.state = .eaten
            } else {
                self.state = .partiallyAvailable(percentage: 1.0 - percentage)
            }

        case .partiallyAvailable(percentage: let availablePercentage):
            if availablePercentage > percentage {
                self.state = .partiallyAvailable(percentage: availablePercentage - percentage)
            } else {
                self.state = .eaten
            }

        case .eaten: throw FoodError.noneRemaining
        }
    }

    static func == (lhs: Food, rhs: Food) -> Bool {
        return lhs.id == rhs.id
    }

    static func create(name: String) -> CreatedFood {
        return CreatedFood(name: name, state: .available)
    }
}

class CreatedFood {
    let name: String
    let state: FoodState

    internal init(name: String, state: FoodState) {
        self.name = name
        self.state = state
    }
}

enum FoodState: Equatable {
    case available
    case partiallyAvailable(percentage: Double)
    case eaten
}

enum FoodError: Error {
    case noneRemaining
}
