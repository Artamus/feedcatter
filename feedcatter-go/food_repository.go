package feedcatter

import (
	"context"
	"database/sql/driver"
	"fmt"
	"slices"
	"time"

	"github.com/uptrace/bun"
)

type FoodRepository interface {
	Create(ctx context.Context, food CreatedFood) (*Food, error)
	FindById(ctx context.Context, id int32) (*Food, error)
	Update(ctx context.Context, food Food) (*Food, error)
	Delete(ctx context.Context, id int32) error
	All(ctx context.Context) ([]*Food, error)
}

type databaseFoodRepository struct {
	db *bun.DB
}

func (r *databaseFoodRepository) Create(ctx context.Context, food CreatedFood) (*Food, error) {
	dbFoodState, err := dbFoodStateOf(food.State)
	if err != nil {
		return nil, err
	}

	insertRow := FoodRow{
		CreatedAt:           time.Now(),
		Name:                food.Name,
		State:               dbFoodState,
		AvailablePercentage: food.AvailablePercentage,
	}

	_, err = r.db.NewInsert().Model(&insertRow).Returning("*").Exec(ctx)
	if err != nil {
		return nil, err
	}

	createdFood, err := foodOf(insertRow)
	if err != nil {
		return nil, err
	}

	return createdFood, nil
}

func (r *databaseFoodRepository) FindById(ctx context.Context, id int32) (*Food, error) {
	foodRow := FoodRow{
		ID: id,
	}

	err := r.db.NewSelect().Model(&foodRow).WherePK().Scan(ctx)
	if err != nil {
		return nil, err
	}

	food, err := foodOf(foodRow)
	if err != nil {
		return nil, err
	}

	return food, nil
}

func (r *databaseFoodRepository) Update(ctx context.Context, food Food) (*Food, error) {
	// To make performance comparisons equal.
	_, err := r.FindById(ctx, food.Id)
	if err != nil {
		return nil, err
	}

	dbFoodState, err := dbFoodStateOf(food.State)
	if err != nil {
		return nil, err
	}

	updateRow := FoodRow{
		ID:                  food.Id,
		CreatedAt:           food.CreatedAt,
		Name:                food.Name,
		State:               dbFoodState,
		AvailablePercentage: food.AvailablePercentage,
	}

	_, err = r.db.NewUpdate().Model(updateRow).WherePK().Exec(ctx)
	if err != nil {
		return nil, err
	}

	return &food, nil
}

func (r *databaseFoodRepository) Delete(ctx context.Context, id int32) error {
	// To make performance comparisons equal.
	_, err := r.FindById(ctx, id)
	if err != nil {
		return err
	}

	_, err = r.db.NewDelete().Where("id = ?", id).Exec(ctx)
	if err != nil {
		return err
	}

	return nil
}

func (r *databaseFoodRepository) All(ctx context.Context) ([]*Food, error) {
	var models []FoodRow
	err := r.db.NewSelect().Model(&models).Where("state IN (?, ?)", stateAvailable, statePartiallyAvailable).Scan(ctx)
	if err != nil {
		return make([]*Food, 0), err
	}

	if len(models) == 0 {
		return make([]*Food, 0), nil
	}

	foods := make([]*Food, len(models))
	for idx, row := range models {
		food, err := foodOf(row)
		if err != nil {
			return make([]*Food, 0), err
		}
		foods[idx] = food
	}

	return foods, nil
}

type FoodRow struct {
	bun.BaseModel       `bun:"table:foods,alias:f"`
	ID                  int32       `bun:"id,pk,autoincrement"`
	CreatedAt           time.Time   `bun:"created_at,notnull,default:current_timestamp"`
	Name                string      `bun:"name"`
	State               dbFoodState `bun:"state"`
	AvailablePercentage float64     `bun:"available_percentage"`
}

type dbFoodState string

const (
	stateAvailable          dbFoodState = "available"
	statePartiallyAvailable dbFoodState = "partiallyAvailable"
	stateEaten              dbFoodState = "eaten"
)

var allDbFoodStates = []dbFoodState{
	stateAvailable,
	statePartiallyAvailable,
	stateEaten,
}

func (s dbFoodState) Value() (driver.Value, error) {
	return string(s), nil
}
func (fs *dbFoodState) Scan(src any) error {
	switch s := src.(type) {
	case []byte:
		*fs = dbFoodState(s)
	case string:
		*fs = dbFoodState(s)
	default:
		return fmt.Errorf("unsupported Scan source for FoodState: %T", src)
	}

	if slices.Contains(allDbFoodStates, *fs) {
		return nil
	}
	return fmt.Errorf("invalid FoodState value retrieved from DB: %s", *fs)
}

func foodOf(row FoodRow) (*Food, error) {
	foodState, err := foodStateOf(row.State)
	if err != nil {
		return nil, err
	}

	return &Food{
		Id:                  row.ID,
		CreatedAt:           row.CreatedAt,
		Name:                row.Name,
		State:               foodState,
		AvailablePercentage: row.AvailablePercentage,
	}, nil
}

func foodStateOf(state dbFoodState) (FoodState, error) {
	switch state {
	case stateAvailable:
		return StateAvailable, nil
	case statePartiallyAvailable:
		return StatePartiallyAvailable, nil
	case stateEaten:
		return StateEaten, nil
	default:
		return StateEaten, fmt.Errorf("invalid food state: %s", state)
	}
}

func dbFoodStateOf(state FoodState) (dbFoodState, error) {
	switch state {
	case StateAvailable:
		return stateAvailable, nil
	case StatePartiallyAvailable:
		return statePartiallyAvailable, nil
	case StateEaten:
		return stateEaten, nil
	}

	return stateEaten, fmt.Errorf("invalid food state: %d", state)
}

func NewDatabaseFoodRepository(db *bun.DB) FoodRepository {
	return &databaseFoodRepository{
		db: db,
	}
}
