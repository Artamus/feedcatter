import Vapor

struct CreateFoodDTO: Content {
    var name: String
}

struct FoodDTO: Content {
    var id: Int
    var createdAt: Date
    var name: String
    var state: FoodStateDTO

    init(from domain: Food) {
        self.id = domain.id!
        self.createdAt = domain.createdAt!
        self.name = domain.name
        self.state =
            switch domain.state {
            case .available: FoodStateDTO.available
            case .partiallyAvailable(let percentage): FoodStateDTO.partiallyAvailable(percentage: percentage)
            case .eaten: FoodStateDTO.eaten
            }
    }

}

enum FoodStateDTO: Content {
    case available
    case partiallyAvailable(percentage: Double)
    case eaten
}
