import Fluent

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class FoodModel: Model, @unchecked Sendable {
    static let schema = "foods"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Field(key: "name")
    var name: String

    @Enum(key: "state")
    var state: DbFoodState

    @Field(key: "available_percentage")
    var availablePercentage: Double

    init() {}

    init(
        id: Int? = nil, createdAt: Date? = nil, name: String, state: DbFoodState,
        availablePercentage: Double
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.availablePercentage = availablePercentage
    }

    func toDomain() throws -> Food {
        if !self.$id.exists {
            throw FoodModelError.missingId
        }
        if self.createdAt == nil {
            throw FoodModelError.missingCreated
        }

        let foodState =
            switch self.state {
            case .available: FoodState.available
            case .partiallyAvailable:
                FoodState.partiallyAvailable(percentage: self.availablePercentage)
            case .eaten: FoodState.eaten
            }

        return Food(id: self.id!, createdAt: self.createdAt!, name: self.name, state: foodState)
    }

    func apply(_ food: Food) {
        let (foodState, availablePercentage) = food.state.dbState()

        self.state = foodState
        self.availablePercentage = availablePercentage
    }

    convenience init(from domain: CreatedFood) {
        let (foodState, availablePercentage) = domain.state.dbState()

        self.init(
            id: nil, createdAt: nil, name: domain.name, state: foodState,
            availablePercentage: availablePercentage
        )
    }

    convenience init(from domain: Food) {
        let (foodState, availablePercentage) = domain.state.dbState()

        self.init(
            id: domain.id, createdAt: domain.createdAt, name: domain.name, state: foodState,
            availablePercentage: availablePercentage
        )
    }
}

enum FoodModelError: Error {
    case missingId
    case missingCreated
}

enum DbFoodState: String, Codable {
    case available
    case partiallyAvailable
    case eaten
}

extension FoodState {
    fileprivate func dbState() -> (DbFoodState, Double) {
        let dbState =
            switch self {
            case .available: DbFoodState.available
            case .partiallyAvailable: DbFoodState.partiallyAvailable
            case .eaten: DbFoodState.eaten
            }

        let availablePercentage =
            switch self {
            case .available: 1.0
            case .partiallyAvailable(let percentage): percentage
            case .eaten: 0.0
            }
        
        return (dbState, availablePercentage)
    }
}
