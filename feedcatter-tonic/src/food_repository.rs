use std::sync::{Arc, Mutex};

use time::OffsetDateTime;

use crate::food::{CreateFood, Food, FoodState};

#[derive(Debug)]
pub struct FoodRepository {
    next_id: Arc<Mutex<i32>>,
    foods: Arc<Mutex<Vec<Food>>>,
}

impl FoodRepository {
    pub fn create(&self, create_food: CreateFood) -> Food {
        let mut next_id = self.next_id.lock().unwrap();

        let food = Food {
            id: *next_id,
            created_at: OffsetDateTime::now_utc(),
            name: create_food.name,
            state: create_food.state,
        };

        *next_id += 1;

        let mut foods = self.foods.lock().unwrap();
        foods.push(food.clone());

        return food;
    }

    pub fn find(&self, id: i32) -> Option<Food> {
        let foods = self.foods.lock().unwrap();
        foods.iter().find(|food| food.id == id).cloned()
    }

    pub fn update(&self, food: Food) {
        let mut foods = self.foods.lock().unwrap();

        let mut updated_foods: Vec<Food> = foods
            .iter()
            .filter(|stored_food| stored_food.id != food.id)
            .cloned()
            .collect();

        updated_foods.push(food);
        *foods = updated_foods;
    }

    pub fn delete(&self, id: i32) {
        let mut foods = self.foods.lock().unwrap();
        foods.retain(|food| food.id != id);
    }

    pub fn all(&self) -> Vec<Food> {
        let foods = self.foods.lock().unwrap();

        foods
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
            next_id: Arc::new(Mutex::new(1)),
            foods: Arc::new(Mutex::new(vec![])),
        }
    }
}
