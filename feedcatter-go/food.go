package feedcatter

import (
	"fmt"
	"time"
)

type Food struct {
	Id        int32
	CreatedAt time.Time
	Name      string
	State     FoodState
}

type FoodState interface {
	isFoodState()
}

type AvailableState struct {
	RemainingPercentage float64
}

func (a AvailableState) isFoodState() {}

type EatenState struct{}

func (a EatenState) isFoodState() {}

func (f *Food) Consume(percentage float64) error {
	switch foo := f.State.(type) {
	case *AvailableState:
		{
			if percentage >= foo.RemainingPercentage {
				f.State = &EatenState{}
			} else {
				f.State = &AvailableState{RemainingPercentage: foo.RemainingPercentage - percentage}
			}
		}
	case *EatenState:
		{
			return fmt.Errorf("no food remaining to be eaten")
		}
	}

	return nil
}

type CreatedFood struct {
	Name  string
	State AvailableState
}

func CreateFood(name string) CreatedFood {
	return CreatedFood{
		Name:  name,
		State: AvailableState{RemainingPercentage: 1.0},
	}
}
