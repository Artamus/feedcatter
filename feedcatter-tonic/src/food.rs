use std::hash::{Hash, Hasher};
use time::OffsetDateTime;

#[derive(Debug, Clone)]
pub struct Food {
    pub id: i32,
    pub created_at: OffsetDateTime,
    pub name: String,
    pub state: FoodState,
}

impl Food {
    pub fn consume(&mut self, percentage: f64) -> Result<(), FoodError> {
        match self.state {
            FoodState::Available => {
                if percentage >= 1.0 {
                    self.state = FoodState::Eaten
                } else {
                    self.state = FoodState::PartiallyAvailable(1.0 - percentage)
                }
                Ok(())
            }
            FoodState::PartiallyAvailable(remaining_percentage) => {
                if remaining_percentage <= percentage {
                    self.state = FoodState::Eaten
                } else {
                    self.state = FoodState::PartiallyAvailable(remaining_percentage - percentage)
                }
                Ok(())
            }
            FoodState::Eaten => Err(FoodError::NoneRemaining),
        }
    }

    pub fn create(name: String) -> CreateFood {
        CreateFood {
            name: name,
            state: FoodState::Available,
        }
    }
}

#[derive(Debug, Clone)]
pub enum FoodState {
    Available,
    PartiallyAvailable(f64),
    Eaten,
}

pub struct CreateFood {
    pub name: String,
    pub state: FoodState,
}

impl PartialEq for Food {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}

impl Eq for Food {}

impl Hash for Food {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.id.hash(state);
    }
}

pub enum FoodError {
    NoneRemaining,
}
