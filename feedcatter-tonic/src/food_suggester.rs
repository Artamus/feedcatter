use std::collections::HashMap;

use crate::food::{Food, FoodState};

pub fn suggest_food(foods: Vec<Food>) -> Option<Food> {
    if foods.is_empty() {
        return None;
    }

    let opened_foods: Vec<Food> = foods
        .iter()
        .filter(|food| match food.state {
            FoodState::PartiallyAvailable(_) => true,
            _ => false,
        })
        .cloned()
        .collect();

    if !opened_foods.is_empty() {
        return opened_foods.first().cloned();
    }

    let most_frequent_food_name = foods
        .iter()
        .fold(HashMap::<Food, usize>::new(), |mut m, food| {
            *m.entry(food.clone()).or_default() += 1;
            m
        })
        .into_iter()
        .max_by_key(|(_, v)| *v)
        .map(|(k, _)| k.name)
        .unwrap();

    let mut most_frequent_food: Vec<Food> = foods
        .iter()
        .filter(|food| food.name == most_frequent_food_name)
        .cloned()
        .collect();
    most_frequent_food.sort_by_key(|food| food.created_at);

    most_frequent_food.first().cloned()
}

#[cfg(test)]
mod tests {
    use time::OffsetDateTime;

    use super::*;

    #[test]
    fn none_when_empty() {
        let suggestion = suggest_food(vec![]);

        assert_eq!(suggestion, None);
    }

    #[test]
    fn prefers_partially_available() {
        let available_food = Food {
            id: 1,
            created_at: OffsetDateTime::from_unix_timestamp(1000).unwrap(),
            name: "Ookeanikala".to_string(),
            state: FoodState::Available,
        };
        let partially_available_food = Food {
            id: 2,
            created_at: OffsetDateTime::from_unix_timestamp(5000).unwrap(),
            name: "Kana".to_string(),
            state: FoodState::PartiallyAvailable(0.5),
        };

        let suggestion = suggest_food(vec![
            available_food.clone(),
            partially_available_food.clone(),
        ]);

        assert_eq!(suggestion, Some(partially_available_food));
    }

    #[test]
    fn prefers_most_abundant_available() {
        let chicken = Food {
            id: 1,
            created_at: OffsetDateTime::from_unix_timestamp(1000).unwrap(),
            name: "Kana".to_string(),
            state: FoodState::Available,
        };
        let older_ocean_fish = Food {
            id: 2,
            created_at: OffsetDateTime::from_unix_timestamp(2000).unwrap(),
            name: "Ookeanikala".to_string(),
            state: FoodState::Available,
        };
        let newer_ocean_fish = Food {
            id: 3,
            created_at: OffsetDateTime::from_unix_timestamp(2000).unwrap(),
            name: "Ookeanikala".to_string(),
            state: FoodState::Available,
        };

        let suggestion = suggest_food(vec![
            chicken.clone(),
            older_ocean_fish.clone(),
            newer_ocean_fish.clone(),
        ]);

        assert_eq!(suggestion, Some(older_ocean_fish));
    }

    #[test]
    fn prefers_oldest_most_abundant_available() {
        let chicken = Food {
            id: 1,
            created_at: OffsetDateTime::from_unix_timestamp(1000).unwrap(),
            name: "Kana".to_string(),
            state: FoodState::Available,
        };
        let older_ocean_fish = Food {
            id: 2,
            created_at: OffsetDateTime::from_unix_timestamp(2000).unwrap(),
            name: "Ookeanikala".to_string(),
            state: FoodState::Available,
        };
        let newer_ocean_fish = Food {
            id: 3,
            created_at: OffsetDateTime::from_unix_timestamp(5000).unwrap(),
            name: "Ookeanikala".to_string(),
            state: FoodState::Available,
        };

        let suggestion = suggest_food(vec![
            chicken.clone(),
            newer_ocean_fish.clone(),
            older_ocean_fish.clone(), // Older ocean fish goes last to ensure we don't just check based on order.
        ]);

        assert_eq!(suggestion, Some(older_ocean_fish));
    }
}
