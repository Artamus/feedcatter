package feedcatter

import (
	"fmt"
	"time"
)

type Food struct {
	Id                  int32
	CreatedAt           time.Time
	Name                string
	State               FoodState
	AvailablePercentage float64
}

type FoodState int

const (
	StateAvailable FoodState = iota
	StatePartiallyAvailable
	StateEaten
)

func (f *Food) Consume(percentage float64) error {
	switch f.State {
	case StateAvailable:
		{
			if percentage >= 1.0 {
				f.State = StateEaten
				f.AvailablePercentage = 0.0
			} else {
				f.State = StatePartiallyAvailable
				f.AvailablePercentage = 1.0 - percentage
			}
		}
	case StatePartiallyAvailable:
		{
			if f.AvailablePercentage > percentage {
				f.AvailablePercentage = f.AvailablePercentage - percentage
			} else {
				f.State = StateEaten
				f.AvailablePercentage = 0.0
			}
		}
	case StateEaten:
		return fmt.Errorf("no food remaining to be eaten")
	}

	return nil
}

type CreatedFood struct {
	Name                string
	State               FoodState
	AvailablePercentage float64
}

func CreateFood(name string) CreatedFood {
	return CreatedFood{
		Name:                name,
		State:               StateAvailable,
		AvailablePercentage: 1.0,
	}
}
