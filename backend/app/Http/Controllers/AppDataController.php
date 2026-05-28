<?php

namespace App\Http\Controllers;

use App\Models\Ingredient;
use App\Models\Recipe;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppDataController extends Controller
{
    public function home(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);

        $ingredients = $user->userIngredients()
            ->with('ingredient')
            ->get()
            ->map(fn ($item) => [
                'id' => $item->ingredient->id,
                'name' => $item->ingredient->name,
                'emoji' => $item->ingredient->emoji,
                'user_ingredient_id' => $item->id,
            ])
            ->values();

        $ingredientIds = $ingredients->pluck('id')->filter()->all();

        $suggestions = Ingredient::query()
            ->when(! empty($ingredientIds), fn ($query) => $query->whereNotIn('id', $ingredientIds))
            ->orderBy('name')
            ->limit(10)
            ->get(['id', 'name', 'emoji']);

        return response()->json([
            'success' => true,
            'data' => [
                'ingredients' => $ingredients,
                'suggestions' => $suggestions,
            ],
        ]);
    }

    public function profile(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);
        $preference = $user->userPreference()->firstOrCreate(
            [],
            ['diet_preferences' => ['Halal']]
        );

        $allergies = Ingredient::orderBy('name')->get()->map(function ($ingredient) use ($user) {
            return [
                'id' => $ingredient->id,
                'name' => $ingredient->name,
                'emoji' => $ingredient->emoji,
                'active' => $user->allergies()->where('ingredient_id', $ingredient->id)->exists(),
            ];
        })->values();

        $availableDietPreferences = ['Vegetarian', 'Vegan', 'Halal', 'Kosher', 'Keto', 'Paleo'];
        $activeDiets = collect($preference->diet_preferences ?? []);
        $dietPreferences = collect($availableDietPreferences)->map(function ($name) use ($activeDiets) {
            return [
                'name' => $name,
                'emoji' => match ($name) {
                    'Vegetarian' => 'vegetarian',
                    'Vegan' => 'eco',
                    'Halal' => 'mosque',
                    'Kosher' => 'star',
                    'Keto' => 'egg',
                    'Paleo' => 'restaurant',
                    default => 'restaurant',
                },
                'active' => $activeDiets->contains($name),
            ];
        })->values();

        $history = $user->recipeHistories()
            ->with('recipe')
            ->latest('cooked_at')
            ->limit(5)
            ->get()
            ->map(fn ($item) => [
                'id' => $item->recipe_id,
                'title' => $item->recipe?->name,
                'date' => optional($item->cooked_at)->diffForHumans(),
            ])
            ->values();

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'name' => $user->name,
                    'email' => $user->email,
                    'favorite_count' => $user->favoriteRecipes()->count(),
                    'recipe_count' => $user->recipeHistories()->count(),
                ],
                'allergies' => $allergies,
                'diet_preferences' => $dietPreferences,
                'settings' => [
                    'notifications_enabled' => $preference->notifications_enabled,
                    'dark_mode' => $preference->dark_mode,
                    'selected_language' => $preference->selected_language,
                    'selected_budget' => $preference->selected_budget,
                ],
                'languages' => ['English', 'French', 'Spanish', 'Arabic'],
                'budgets' => ['Low', 'Medium', 'High'],
                'history' => $history,
            ],
        ]);
    }

    public function updateSettings(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'notifications_enabled' => 'nullable|boolean',
            'dark_mode' => 'nullable|boolean',
            'selected_language' => 'nullable|string|max:50',
            'selected_budget' => 'nullable|string|max:50',
            'diet_preferences' => 'nullable|array',
            'diet_preferences.*' => 'string|max:50',
        ]);

        $user = $this->resolveUser($request);
        $preference = $user->userPreference()->firstOrCreate([]);
        $preference->fill($validated);
        $preference->save();

        return response()->json([
            'success' => true,
            'message' => 'Settings updated',
        ]);
    }

    public function searchBootstrap(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);

        $recentSearches = $user->searchHistories()
            ->latest('searched_at')
            ->limit(5)
            ->pluck('query')
            ->unique()
            ->values();

        $trendingRecipes = Recipe::orderBy('id')->limit(6)->pluck('name')->values();
        $suggestions = Recipe::orderBy('name')->limit(5)->pluck('name')->values();

        return response()->json([
            'success' => true,
            'data' => [
                'recent_searches' => $recentSearches,
                'trending_recipes' => $trendingRecipes,
                'suggestions' => $suggestions,
            ],
        ]);
    }

    public function search(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'q' => 'nullable|string|max:255',
            'filters' => 'nullable|array',
            'filters.*' => 'string|max:50',
        ]);

        $query = Recipe::with('ingredients');
        $search = strtolower(trim($validated['q'] ?? ''));
        $filters = collect($validated['filters'] ?? [])->map(fn ($item) => strtolower($item))->values();

        if ($search !== '') {
            $query->where(function ($builder) use ($search) {
                $builder
                    ->whereRaw('LOWER(name) like ?', ["%{$search}%"])
                    ->orWhereRaw('LOWER(category) like ?', ["%{$search}%"])
                    ->orWhereRaw('LOWER(description) like ?', ["%{$search}%"]);
            });
        }

        if ($filters->contains('easy')) {
            $query->where('difficulty', 'Easy');
        }
        if ($filters->contains('medium')) {
            $query->where('difficulty', 'Medium');
        }
        if ($filters->contains('hard')) {
            $query->where('difficulty', 'Hard');
        }
        if ($filters->contains('quick')) {
            $query->where('time', '<=', 15);
        }
        if ($filters->contains('vegetarian')) {
            $query->where('is_vegetarian', true);
        }
        if ($filters->contains('vegan')) {
            $query->where('is_vegetarian', true);
        }

        $recipes = $query->limit(30)->get()->map(function (Recipe $recipe) use ($search) {
            $matchingIngredients = $recipe->ingredients
                ->filter(fn ($ingredient) => $search !== '' && str_contains(strtolower($ingredient->name), $search))
                ->pluck('name')
                ->values();

            return [
                'id' => $recipe->id,
                'title' => $recipe->name,
                'image' => $recipe->image,
                'category' => $recipe->category,
                'prepTime' => $recipe->time,
                'difficulty' => $recipe->difficulty,
                'isFavorite' => false,
                'matchingIngredients' => $matchingIngredients,
                'description' => $recipe->description,
                'tags' => collect([
                    $recipe->is_vegetarian ? 'vegetarian' : null,
                    $recipe->time <= 15 ? 'quick' : null,
                    strtolower($recipe->difficulty),
                ])->filter()->values(),
            ];
        })->values();

        if ($search !== '') {
            $user = $this->resolveUser($request);
            $user->searchHistories()->create([
                'query' => $validated['q'],
                'searched_at' => now(),
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $recipes,
        ]);
    }
}
