import GRPCCore

struct FeedcatterService: Feedcatter_FeedcatterService.SimpleServiceProtocol {
    func createFood(request: Feedcatter_CreateFoodRequest, context: ServerContext) async throws
        -> Feedcatter_CreateFoodResponse
    {
        return Feedcatter_CreateFoodResponse()
    }

    func deleteFood(request: Feedcatter_DeleteFoodRequest, context: ServerContext) async throws
        -> Feedcatter_DeleteFoodResponse
    {
        return Feedcatter_DeleteFoodResponse()
    }

    func listFoods(request: Feedcatter_ListFoodsRequest, context: ServerContext) async throws
        -> Feedcatter_ListFoodsResponse
    { return Feedcatter_ListFoodsResponse() }

    func suggestFood(request: Feedcatter_SuggestFoodRequest, context: ServerContext) async throws
        -> Feedcatter_SuggestFoodResponse
    { return Feedcatter_SuggestFoodResponse() }
    
    func feedFood(request: Feedcatter_FeedFoodRequest, context: ServerContext) async throws
        -> Feedcatter_FeedFoodResponse
    { return Feedcatter_FeedFoodResponse() }
}
