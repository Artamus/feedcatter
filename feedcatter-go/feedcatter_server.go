package feedcatter

import (
	"context"
	"fmt"

	pb "github.com/Artamus/feedcatter/feedcatter-go/feedcatter"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type feedcatterServer struct {
	pb.UnimplementedFeedcatterServiceServer
	foodRepository FoodRepository
}

func (s *feedcatterServer) CreateFood(ctx context.Context, in *pb.CreateFoodRequest) (*pb.CreateFoodResponse, error) {

	createdFood := CreateFood(in.GetName())
	food, err := s.foodRepository.Create(ctx, createdFood)
	if err != nil {
		return nil, err
	}

	protoFood, err := protoFoodOf(food)
	if err != nil {
		return nil, err
	}
	return &pb.CreateFoodResponse{Food: protoFood}, nil
}

func (s *feedcatterServer) DeleteFood(ctx context.Context, in *pb.DeleteFoodRequest) (*pb.DeleteFoodResponse, error) {

	err := s.foodRepository.Delete(ctx, in.Food)
	if err != nil {
		return nil, err
	}

	return &pb.DeleteFoodResponse{}, nil
}

func (s *feedcatterServer) ListFoods(ctx context.Context, in *pb.ListFoodsRequest) (*pb.ListFoodsResponse, error) {

	foods, err := s.foodRepository.All(ctx)
	if err != nil {
		return nil, err
	}

	protoFoods := make([]*pb.Food, len(foods))
	for idx, food := range foods {
		protoFood, err := protoFoodOf(food)
		if err != nil {
			return nil, err
		}
		protoFoods[idx] = protoFood
	}

	return &pb.ListFoodsResponse{Foods: protoFoods}, nil
}

func (s *feedcatterServer) SuggestFood(ctx context.Context, in *pb.SuggestFoodRequest) (*pb.SuggestFoodResponse, error) {

	foods, err := s.foodRepository.All(ctx)
	if err != nil {
		return nil, err
	}

	suggestion := SuggestFood(foods)
	if suggestion == nil {
		return nil, fmt.Errorf("unable to suggest food")
	}

	protoSuggestion, err := protoFoodOf(suggestion)
	if err != nil {
		return nil, err
	}

	return &pb.SuggestFoodResponse{Food: protoSuggestion}, nil
}

func (s *feedcatterServer) FeedFood(ctx context.Context, in *pb.FeedFoodRequest) (*pb.FeedFoodResponse, error) {

	food, err := s.foodRepository.FindById(ctx, in.Food)
	if err != nil {
		return nil, err
	}

	err = food.Consume(in.GetPercentage())
	if err != nil {
		return nil, err
	}

	savedFood, err := s.foodRepository.Update(ctx, *food)
	if err != nil {
		return nil, err
	}

	protoFood, err := protoFoodOf(savedFood)
	if err != nil {
		return nil, err
	}
	return &pb.FeedFoodResponse{Food: protoFood}, nil
}

func protoFoodOf(food *Food) (*pb.Food, error) {
	protoFoodState, err := protoFoodStateOf(food.State)
	if err != nil {
		return nil, err
	}
	availablePercentage, err := availablePercentageOf(food.State)
	if err != nil {
		return nil, err
	}

	return &pb.Food{
		Id:                  food.Id,
		CreatedAt:           timestamppb.New(food.CreatedAt),
		Name:                food.Name,
		State:               protoFoodState,
		AvailablePercentage: availablePercentage,
	}, nil
}

func protoFoodStateOf(foodState FoodState) (pb.Food_FoodState, error) {
	switch state := foodState.(type) {
	case AvailableState:
		{
			if state.RemainingPercentage >= 1.0 {
				return pb.Food_AVAILABLE, nil
			} else {
				return pb.Food_PARTIALLY_AVAILABLE, nil
			}
		}

	case EatenState:
		return pb.Food_EATEN, nil
	}

	return pb.Food_STATE_UNSPECIFIED, fmt.Errorf("unknown FoodState value: %d", foodState)
}

func availablePercentageOf(foodState FoodState) (float64, error) {
	switch state := foodState.(type) {
	case AvailableState:
		return state.RemainingPercentage, nil

	case EatenState:
		return 0.0, nil
	}

	return 0.0, fmt.Errorf("unknown FoodState value: %d", foodState)
}

func NewServer(foodRepo FoodRepository) *feedcatterServer {
	return &feedcatterServer{foodRepository: foodRepo}
}
