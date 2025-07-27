use tonic::{Request, Response, Status, transport::Server};

use feedcatter::feedcatter_service_server::{FeedcatterService, FeedcatterServiceServer};

use feedcatter::{
    CreateFoodRequest, CreateFoodResponse, DeleteFoodRequest, DeleteFoodResponse, FeedFoodRequest,
    FeedFoodResponse, ListFoodsRequest, ListFoodsResponse, SuggestFoodRequest, SuggestFoodResponse,
};

pub mod feedcatter {
    tonic::include_proto!("feedcatter");
}

#[derive(Debug, Default)]
pub struct MyFeedcatterService {}

#[tonic::async_trait]
impl FeedcatterService for MyFeedcatterService {
    async fn create_food(
        &self,
        _request: Request<CreateFoodRequest>,
    ) -> Result<Response<CreateFoodResponse>, Status> {
        let resp = CreateFoodResponse { food: None };
        Ok(Response::new(resp))
    }

    async fn delete_food(
        &self,
        _request: Request<DeleteFoodRequest>,
    ) -> Result<Response<DeleteFoodResponse>, Status> {
        let resp = DeleteFoodResponse {};
        Ok(Response::new(resp))
    }

    async fn list_foods(
        &self,
        _request: Request<ListFoodsRequest>,
    ) -> Result<Response<ListFoodsResponse>, Status> {
        let resp = ListFoodsResponse { foods: vec![] };
        Ok(Response::new(resp))
    }

    async fn suggest_food(
        &self,
        _request: Request<SuggestFoodRequest>,
    ) -> Result<Response<SuggestFoodResponse>, Status> {
        let resp = SuggestFoodResponse { food: None };
        Ok(Response::new(resp))
    }

    async fn feed_food(
        &self,
        _request: Request<FeedFoodRequest>,
    ) -> Result<Response<FeedFoodResponse>, Status> {
        let resp = FeedFoodResponse { food: None };
        Ok(Response::new(resp))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50051".parse()?;
    let feedcatter = MyFeedcatterService::default();

    Server::builder()
        .add_service(FeedcatterServiceServer::new(feedcatter))
        .serve(addr)
        .await?;

    Ok(())
}
