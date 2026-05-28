<?php

namespace App\Http\Controllers;

use App\Models\MealPlan;
use App\Models\Recipe;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MealPlanController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);
        $start = Carbon::parse($request->query('week_start', now()->startOfWeek()->toDateString()))->startOfDay();
        $end = (clone $start)->addDays(6)->endOfDay();

        $plans = $user->mealPlans()
            ->with('recipe.ingredients')
            ->whereBetween('planned_date', [$start->toDateString(), $end->toDateString()])
            ->get();

        $weekMeals = [];
        for ($i = 0; $i < 7; $i++) {
            $weekMeals["day_{$i}"] = [];
        }

        foreach ($plans as $plan) {
            $dayIndex = $start->diffInDays(Carbon::parse($plan->planned_date));
            $weekMeals["day_{$dayIndex}"][strtolower($plan->meal_type)] = [
                'id' => (string) $plan->recipe->id,
                'name' => $plan->recipe->name,
                'image' => $plan->recipe->image,
                'prepTime' => $plan->recipe->time,
                'difficulty' => $plan->recipe->difficulty,
            ];
        }

        $tips = $this->buildBatchCookingTips($plans);

        return response()->json([
            'success' => true,
            'data' => [
                'weekMeals' => $weekMeals,
                'batchCookingTips' => $tips,
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'planned_date' => 'required|date',
            'meal_type' => 'required|string|max:50',
            'recipe_id' => 'required|exists:recipes,id',
        ]);

        $user = $this->resolveUser($request);

        $user->mealPlans()->updateOrCreate(
            [
                'planned_date' => $validated['planned_date'],
                'meal_type' => strtolower($validated['meal_type']),
            ],
            ['recipe_id' => $validated['recipe_id']],
        );

        return response()->json([
            'success' => true,
            'message' => 'Meal slot updated',
        ]);
    }

    public function destroy(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'planned_date' => 'required|date',
            'meal_type' => 'required|string|max:50',
        ]);

        $user = $this->resolveUser($request);
        $user->mealPlans()
            ->where('planned_date', $validated['planned_date'])
            ->where('meal_type', strtolower($validated['meal_type']))
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Meal removed',
        ]);
    }

    private function buildBatchCookingTips($plans): array
    {
        $ingredientUsage = [];

        foreach ($plans as $plan) {
            foreach ($plan->recipe->ingredients as $ingredient) {
                $ingredientUsage[$ingredient->name] = ($ingredientUsage[$ingredient->name] ?? 0) + 1;
            }
        }

        $reusedIngredients = collect($ingredientUsage)
            ->filter(fn ($count) => $count > 1)
            ->sortDesc()
            ->keys()
            ->take(4)
            ->values();

        if ($reusedIngredients->isEmpty()) {
            return [];
        }

        return [[
            'type' => 'ingredient_prep',
            'title' => 'Prep shared ingredients once',
            'description' => 'These ingredients appear in multiple meals this week. Prep them in one batch to save time.',
            'timeSaved' => $reusedIngredients->count() * 5,
            'ingredients' => $reusedIngredients,
            'recipes' => $plans->pluck('recipe.name')->unique()->values(),
        ]];
    }
}
