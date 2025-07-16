import Vapor

struct CreateFoodDTO: Content {
    var name: String
}

struct FoodDTO: Content, Equatable {
    let id: Int
    let createdAt: Date
    let name: String
    let state: FoodDTOState

    init(id: Int, createdAt: Date, name: String, state: FoodDTOState) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.state = state
    }

    init(from domain: Food) {
        self.id = domain.id!
        self.createdAt = domain.createdAt!
        self.name = domain.name
        self.state =
            switch domain.state {
            case .available: FoodDTOState.available
            case .partiallyAvailable(let percentage):
                FoodDTOState.partiallyAvailable(percentage: percentage)
            case .eaten: FoodDTOState.eaten
            }
    }

    static func == (lhs: FoodDTO, rhs: FoodDTO) -> Bool {
        return lhs.id == rhs.id
            && Int(lhs.createdAt.timeIntervalSince1970) == Int(rhs.createdAt.timeIntervalSince1970)
            && lhs.name == rhs.name
            && lhs.state == rhs.state
    }
}

enum FoodDTOState: Content, Equatable {
    case available
    case partiallyAvailable(percentage: Double)
    case eaten
}
