package feedcatter

import (
	"testing"
	"time"
)

func TestSuggestsNothingIfEmpty(t *testing.T) {
	suggestion := SuggestFood(make([]*Food, 0))

	if suggestion != nil {
		t.Errorf(`SuggestFood([]) = %v, want nil`, suggestion)
	}
}

func TestPrefersPartiallyEaten(t *testing.T) {
	availableFood := &Food{
		Id: 1, CreatedAt: time.Now(), Name: "Ookeanikala", State: &AvailableState{RemainingPercentage: 1.0},
	}
	partiallyEatenFood := &Food{
		Id: 2, CreatedAt: time.Now(), Name: "Ookeanikala", State: &AvailableState{RemainingPercentage: 0.5},
	}

	suggestion := SuggestFood([]*Food{availableFood, partiallyEatenFood})

	if suggestion != partiallyEatenFood {
		t.Errorf(`SuggestFood([...]) = %v, want %v`, suggestion, partiallyEatenFood)
	}
}

func TestPrefersMostAbundant(t *testing.T) {
	chicken := &Food{
		Id: 1, CreatedAt: time.UnixMilli(1000), Name: "Kana", State: &AvailableState{RemainingPercentage: 1.0},
	}
	olderOceanFish := &Food{
		Id: 2, CreatedAt: time.UnixMilli(2000), Name: "Ookeanikala", State: &AvailableState{RemainingPercentage: 1.0},
	}
	newerOceanFish := &Food{
		Id: 3, CreatedAt: time.UnixMilli(5000), Name: "Ookeanikala", State: &AvailableState{RemainingPercentage: 1.0},
	}

	suggestion := SuggestFood([]*Food{chicken, olderOceanFish, newerOceanFish})

	if suggestion != olderOceanFish {
		t.Errorf(`SuggestFood([...]) = %v, want %v`, suggestion, olderOceanFish)
	}
}

func TestPrefersOldestMostAbundant(t *testing.T) {
	chicken := &Food{
		Id: 1, CreatedAt: time.UnixMilli(1000), Name: "Kana", State: &AvailableState{RemainingPercentage: 1.0},
	}
	olderOceanFish := &Food{
		Id: 2, CreatedAt: time.UnixMilli(2000), Name: "Ookeanikala", State: &AvailableState{RemainingPercentage: 1.0},
	}
	newerOceanFish := &Food{
		Id: 3, CreatedAt: time.UnixMilli(5000), Name: "Ookeanikala", State: &AvailableState{RemainingPercentage: 1.0},
	}

	suggestion := SuggestFood([]*Food{chicken, newerOceanFish, olderOceanFish}) // Older ocean fish goes last to ensure we don't just check based on order.

	if suggestion != olderOceanFish {
		t.Errorf(`SuggestFood([...]) = %v, want %v`, suggestion, olderOceanFish)
	}
}
