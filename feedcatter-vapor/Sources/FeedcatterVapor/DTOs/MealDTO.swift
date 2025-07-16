import Vapor

struct CreateMealDTO: Content {
    let food: Int
    let percentage: Double
}