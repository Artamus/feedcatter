use sqlx::{Pool, Postgres, Row, postgres::PgRow};
use time::OffsetDateTime;

use crate::food::{CreateFood, Food, FoodState};

#[derive(Debug)]
pub struct FoodRepository {
    db: Pool<Postgres>,
}

impl FoodRepository {
    pub async fn create(&self, create_food: CreateFood) -> Food {
        let (db_food_state, available_percentage) = db_food_state_of(create_food.state);

        let inserted = sqlx::query(
            r#"
INSERT INTO foods ( created_at, name, state, available_percentage )
VALUES ( $1, $2, $3, $4 )
RETURNING *
        "#,
        )
        .bind(OffsetDateTime::now_utc())
        .bind(create_food.name)
        .bind(db_food_state)
        .bind(available_percentage)
        .fetch_one(&self.db)
        .await
        .unwrap();

        return food_of(inserted).unwrap();
    }

    pub async fn find(&self, id: i32) -> Option<Food> {
        sqlx::query(
            r#"
SELECT id, created_at, name, state, available_percentage
FROM foods
WHERE id = $1
        "#,
        )
        .bind(id)
        .map(|row: PgRow| -> Option<Food> { food_of(row).ok() })
        .fetch_one(&self.db)
        .await
        .ok()?
    }

    pub async fn update(&self, food: Food) {
        let _ = self.find(food.id).await; // Parity for comparing to ORM.

        let (db_food_state, available_percentage) = db_food_state_of(food.state);

        sqlx::query(
            "UPDATE foods SET name = $1, state = $2, available_percentage = $3 WHERE id = $4",
        )
        .bind(food.name)
        .bind(db_food_state)
        .bind(available_percentage)
        .bind(food.id)
        .execute(&self.db)
        .await
        .unwrap();
    }

    pub async fn delete(&self, id: i32) {
        let _ = self.find(id).await; // Parity for comparing to ORM.

        sqlx::query("DELETE FROM foods WHERE id = $1")
            .bind(id)
            .execute(&self.db)
            .await
            .unwrap();
    }

    pub async fn all(&self) -> Vec<Food> {
        sqlx::query(
            r#"
SELECT id, created_at, name, state, available_percentage
FROM foods
WHERE state IN ('available'::food_state, 'partiallyAvailable'::food_state)
        "#,
        )
        .map(|row: PgRow| -> Option<Food> { food_of(row).ok() })
        .fetch_all(&self.db)
        .await
        .unwrap()
        .into_iter()
        .flatten()
        .collect::<Vec<Food>>()
    }

    pub fn new(pool: Pool<Postgres>) -> FoodRepository {
        FoodRepository { db: pool }
    }
}

#[derive(sqlx::Type)]
#[sqlx(type_name = "food_state")]
enum DbFoodState {
    #[sqlx(rename = "available")]
    Available,
    #[sqlx(rename = "partiallyAvailable")]
    PartiallyAvailable,
    #[sqlx(rename = "eaten")]
    Eaten,
}

fn db_food_state_of(food_state: FoodState) -> (DbFoodState, f64) {
    match food_state {
        FoodState::Available => (DbFoodState::Available, 1.0),
        FoodState::PartiallyAvailable(remaining_percentage) => {
            (DbFoodState::PartiallyAvailable, remaining_percentage)
        }
        FoodState::Eaten => (DbFoodState::Eaten, 0.0),
    }
}

fn food_state_of(db_food_state: DbFoodState, available_percentage: f64) -> FoodState {
    match db_food_state {
        DbFoodState::Available => FoodState::Available,
        DbFoodState::PartiallyAvailable => FoodState::PartiallyAvailable(available_percentage),
        DbFoodState::Eaten => FoodState::Eaten,
    }
}

fn food_of(row: PgRow) -> Result<Food, String> {
    let raw_id: i64 = row.try_get("id").or(Err("cannot get column 'id'"))?;
    let food_state: DbFoodState = row.try_get("state").or(Err("cannot get column 'state'"))?;
    let available_percentage: f64 = row
        .try_get("available_percentage")
        .or(Err("cannot get column 'available_percentage'"))?;

    return Ok(Food {
        id: i32::try_from(raw_id).or(Err("could not convert id to i32"))?,
        created_at: row
            .try_get("created_at")
            .or(Err("cannot get column 'created_at'"))?,
        name: row.try_get("name").or(Err("cannot get column 'name'"))?,
        state: food_state_of(food_state, available_percentage),
    });
}
