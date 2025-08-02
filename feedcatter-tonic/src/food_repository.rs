use time::OffsetDateTime;

use crate::food;

#[derive(Debug, Default)]
pub struct FoodRepository {
    foods: Vec<food::Food>,
}

impl FoodRepository {
    pub fn create(&mut self, create_food: food::CreateFood) -> food::Food {
        let food = food::Food {
            id: 1,
            created_at: OffsetDateTime::now_utc(),
            name: create_food.name,
            state: create_food.state,
        };
        self.foods.push(food.clone());
        return food;
    }
}
