use time::OffsetDateTime;

use crate::food;

#[derive(Debug)]
pub struct FoodRepository {
    next_id: i32,
    foods: Vec<food::Food>,
}

impl FoodRepository {
    pub fn create(&mut self, create_food: food::CreateFood) -> food::Food {
        let food = food::Food {
            id: self.next_id,
            created_at: OffsetDateTime::now_utc(),
            name: create_food.name,
            state: create_food.state,
        };
        self.next_id += 1;
        self.foods.push(food.clone());
        return food;
    }

    pub fn new() -> FoodRepository {
        FoodRepository {
            next_id: 1,
            foods: vec![],
        }
    }
}
