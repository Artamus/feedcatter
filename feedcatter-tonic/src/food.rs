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
