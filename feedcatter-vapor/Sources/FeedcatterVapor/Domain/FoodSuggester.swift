func suggestFood(choice foods: [Food]) -> Food? {
    if foods.isEmpty {
        return nil
    }

    let openedFoods = foods.filter { food in
        switch food.state {
        case .partiallyAvailable: return true
        default: return false
        }
    }

    if !openedFoods.isEmpty {
        return openedFoods.first!
    }

    let countByName = foods.reduce(into: [:]) { result, food in
        result[food.name, default: 0] += 1
    }
    let (mostFrequentFoodName, _) = countByName.max(by: { $0.value < $1.value })!

    let mostFrequentFood =
        foods
        .filter { $0.name == mostFrequentFoodName }
        .sorted(by: { $0.createdAt! < $1.createdAt! })

    return mostFrequentFood.first
}
