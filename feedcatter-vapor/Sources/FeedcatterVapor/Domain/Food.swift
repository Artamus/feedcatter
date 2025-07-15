import Foundation

class Food {
    var id: Int?
    var createdAt: Date?
    var name: String
    var state: FoodState

    init(id: Int? = nil, createdAt: Date? = nil, name: String) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.state = .available
    }

    init(id: Int, createdAt: Date, name: String, state: FoodState) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.state = state
    }
}

enum FoodState {
    case available
    case partiallyAvailable(percentage: Double)
    case eaten
}
