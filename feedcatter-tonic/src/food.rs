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
