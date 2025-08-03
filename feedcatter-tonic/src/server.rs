use prost_types::Timestamp;
use time::OffsetDateTime;
use tonic::{Request, Response, Status, transport::Server};

use feedcatter_pb::feedcatter_service_server::{FeedcatterService, FeedcatterServiceServer};

use feedcatter_pb::{
    CreateFoodRequest, CreateFoodResponse, DeleteFoodRequest, DeleteFoodResponse, FeedFoodRequest,
    FeedFoodResponse, ListFoodsRequest, ListFoodsResponse, SuggestFoodRequest, SuggestFoodResponse,
};

use crate::food::FoodState;

pub mod feedcatter_pb {
    tonic::include_proto!("feedcatter");
}

mod food;
mod food_repository;
mod food_suggester;

#[derive(Debug)]
pub struct MyFeedcatterService {
    food_repository: food_repository::FoodRepository,
}

#[tonic::async_trait]
impl FeedcatterService for MyFeedcatterService {
    async fn create_food(
        &self,
        req: Request<CreateFoodRequest>,
    ) -> Result<Response<CreateFoodResponse>, Status> {
        let create_food = food::Food::create(req.into_inner().name);

        let food = self.food_repository.create(create_food);

        Ok(Response::new(CreateFoodResponse {
            food: Some(proto_food_of(food)),
        }))
    }

    async fn delete_food(
        &self,
        req: Request<DeleteFoodRequest>,
    ) -> Result<Response<DeleteFoodResponse>, Status> {
        self.food_repository.delete(req.into_inner().food);

        Ok(Response::new(DeleteFoodResponse {}))
    }

    async fn list_foods(
        &self,
        _req: Request<ListFoodsRequest>,
    ) -> Result<Response<ListFoodsResponse>, Status> {
        let foods: Vec<feedcatter_pb::Food> = self
            .food_repository
            .all()
            .iter()
            .map(|food| proto_food_of(food.clone()))
            .collect();

        Ok(Response::new(ListFoodsResponse { foods: foods }))
    }

    async fn suggest_food(
        &self,
        _req: Request<SuggestFoodRequest>,
    ) -> Result<Response<SuggestFoodResponse>, Status> {
        let all_foods = self.food_repository.all();
        let suggested_food = food_suggester::suggest_food(all_foods);

        match suggested_food {
            None => Err(Status::internal("unable to suggest food")),
            Some(food) => Ok(Response::new(SuggestFoodResponse {
                food: Some(proto_food_of(food)),
            })),
        }
    }

    async fn feed_food(
        &self,
        _request: Request<FeedFoodRequest>,
    ) -> Result<Response<FeedFoodResponse>, Status> {
        let resp = FeedFoodResponse { food: None };
        Ok(Response::new(resp))
    }
}

fn proto_food_of(food: food::Food) -> feedcatter_pb::Food {
    let (pb_food_state, pb_available_percentage) = pb_food_state_of(food.state);

    return feedcatter_pb::Food {
        id: food.id,
        created_at: Some(pb_timestamp_of(food.created_at)),
        name: food.name,
        state: pb_food_state.into(),
        available_percentage: pb_available_percentage,
    };
}

fn pb_timestamp_of(time: OffsetDateTime) -> Timestamp {
    let nanos = i32::try_from(time.nanosecond()).unwrap(); // Maximum value is less than 10^9.
    return Timestamp {
        seconds: time.unix_timestamp(),
        nanos: nanos,
    };
}

fn pb_food_state_of(food_state: FoodState) -> (feedcatter_pb::food::FoodState, f64) {
    match food_state {
        FoodState::Available => (feedcatter_pb::food::FoodState::Available, 1.0),
        FoodState::PartiallyAvailable(remaining_percentage) => (
            feedcatter_pb::food::FoodState::PartiallyAvailable,
            remaining_percentage,
        ),
        FoodState::Eaten => (feedcatter_pb::food::FoodState::Eaten, 0.0),
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50051".parse()?;

    let feedcatter = MyFeedcatterService {
        food_repository: food_repository::FoodRepository::new(),
    };

    Server::builder()
        .add_service(FeedcatterServiceServer::new(feedcatter))
        .serve(addr)
        .await?;

    Ok(())
}
