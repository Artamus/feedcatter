import GRPCCore
import PostgresKit
import SwiftProtobuf

struct FeedcatterService: Feedcatter_FeedcatterService.SimpleServiceProtocol {
    let foodRepository: FoodRepository
    let dbPool: PostgresDatabase
    init(foodRepository: FoodRepository, dbPool: PostgresDatabase) {
        self.foodRepository = foodRepository
        self.dbPool = dbPool
    }

    func createFood(request: Feedcatter_CreateFoodRequest, context: ServerContext) async throws
        -> Feedcatter_CreateFoodResponse
    {
        let createdFood = Food.create(name: request.name)
        let food = try await self.foodRepository.create(createdFood, on: self.dbPool.sql())

        return Feedcatter_CreateFoodResponse.with {
            $0.food = food.toProtoFood()
        }
    }

    func deleteFood(request: Feedcatter_DeleteFoodRequest, context: ServerContext) async throws
        -> Feedcatter_DeleteFoodResponse
    {
        try await self.foodRepository.delete(id: Int(request.food), on: self.dbPool.sql())

        return Feedcatter_DeleteFoodResponse()
    }

    func listFoods(request: Feedcatter_ListFoodsRequest, context: ServerContext) async throws
        -> Feedcatter_ListFoodsResponse
    {
        let foods = try await self.foodRepository.all(on: self.dbPool.sql())
        return Feedcatter_ListFoodsResponse.with {
            $0.foods = foods.map { $0.toProtoFood() }
        }
    }

    func suggestFood(request: Feedcatter_SuggestFoodRequest, context: ServerContext) async throws
        -> Feedcatter_SuggestFoodResponse
    {
        let foods = try await self.foodRepository.all(on: self.dbPool.sql())

        if foods.isEmpty {
            throw RPCError(code: .notFound, message: "no foods found")
        }

        let suggestion = feedcatter_grpc.suggestFood(choice: foods)
        if suggestion == nil {
            throw RPCError(code: .internalError, message: "unable to suggest food")
        }

        return Feedcatter_SuggestFoodResponse.with {
            $0.food = suggestion!.toProtoFood()
        }
    }

    func feedFood(request: Feedcatter_FeedFoodRequest, context: ServerContext) async throws
        -> Feedcatter_FeedFoodResponse
    {
        guard
            let food = try await self.foodRepository.find(
                id: Int(request.food), on: self.dbPool.sql())
        else {
            throw RPCError(code: .notFound, message: "food \(request.food) not found")
        }

        do {
            try food.consume(percentage: request.percentage)
        } catch FoodError.noneRemaining {
            throw RPCError(
                code:
                    .failedPrecondition, message: "unable to consume food that is already eaten")
        }

        let updatedFood = try await self.foodRepository.update(food, on: self.dbPool.sql())
        return Feedcatter_FeedFoodResponse.with {
            $0.food = updatedFood.toProtoFood()
        }
    }
}

extension Food {
    func toProtoFood() -> Feedcatter_Food {
        let (state, availablePercentage) = self.state.toProtoFoodState()

        return Feedcatter_Food.with {
            $0.id = Int32(self.id)
            $0.createdAt = Google_Protobuf_Timestamp(
                roundingTimeIntervalSince1970: self.createdAt.timeIntervalSince1970)
            $0.name = self.name
            $0.state = state
            $0.availablePercentage = availablePercentage
        }
    }
}

extension FoodState {
    func toProtoFoodState() -> (Feedcatter_Food.FoodState, Double) {
        switch self {
        case .available: (Feedcatter_Food.FoodState.available, 1.0)
        case .partiallyAvailable(let percentage):
            (Feedcatter_Food.FoodState.partiallyAvailable, percentage)
        case .eaten: (Feedcatter_Food.FoodState.eaten, 0.0)
        }
    }
}
