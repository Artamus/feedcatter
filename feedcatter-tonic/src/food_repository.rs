use time::OffsetDateTime;

use crate::food::{CreateFood, Food, FoodState};

#[derive(Debug)]
pub struct FoodRepository {
    next_id: i32,
    foods: Vec<Food>,
}

impl FoodRepository {
    pub fn create(&mut self, create_food: CreateFood) -> Food {
        let food = Food {
            id: self.next_id,
            created_at: OffsetDateTime::now_utc(),
            name: create_food.name,
            state: create_food.state,
        };
        self.next_id += 1;
        self.foods.push(food.clone());
        return food;
    }

    pub fn delete(&mut self, id: i32) {
        self.foods.retain(|food| food.id != id);
    }

    pub fn all(&self) -> Vec<Food> {
        self.foods
            .iter()
            .filter(|food| match food.state {
                FoodState::Eaten => false,
                _ => true,
            })
            .cloned()
            .collect()
    }

    pub fn new() -> FoodRepository {
        FoodRepository {
            next_id: 1,
            foods: vec![],
        }
    }
}
