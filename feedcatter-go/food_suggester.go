package feedcatter

import (
	"slices"
)

func SuggestFood(foods []*Food) *Food {
	if len(foods) == 0 {
		return nil
	}

	openedFoods := make([]*Food, 0)
	for _, food := range foods {
		if food.State == StatePartiallyAvailable {
			openedFoods = append(openedFoods, food)
		}
	}
	if len(openedFoods) > 0 {
		return openedFoods[0]
	}

	counts := make(map[string]int)
	for _, food := range foods {
		counts[food.Name] += 1
	}

	maxCount := 0
	maxFood := ""
	for k, v := range counts {
		if v > maxCount {
			maxCount = v
			maxFood = k
		}
	}

	mostCommonFoods := make([]*Food, maxCount)
	idx := 0
	for _, food := range foods {
		if food.Name == maxFood {
			mostCommonFoods[idx] = food
			idx++
		}
	}

	slices.SortFunc(mostCommonFoods, func(i, j *Food) int {
		return i.CreatedAt.Compare(j.CreatedAt)
	})

	return mostCommonFoods[0]
}
