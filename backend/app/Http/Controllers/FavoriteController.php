<?php

namespace App\Http\Controllers;

use App\Models\Recipe;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);

        $favorites = $user->favoriteRecipes()
            ->with('recipe.ingredients')
            ->latest()
            ->get()
            ->map(function ($favorite) {
                $recipe = $favorite->recipe;

                return [
                    'id' => $recipe->id,
                    'title' => $recipe->name,
                    'description' => $recipe->description,
                    'image' => $recipe->image,
                    'prepTime' => "{$recipe->time} min",
                    'difficulty' => $recipe->difficulty,
                    'servings' => $recipe->servings,
                    'category' => $recipe->category,
                    'isFavorite' => true,
                ];
            })
            ->values();

        return response()->json([
            'success' => true,
            'data' => $favorites,
        ]);
    }

    public function store(Request $request, int $recipeId): JsonResponse
    {
        $user = $this->resolveUser($request);
        Recipe::findOrFail($recipeId);

        $user->favoriteRecipes()->firstOrCreate([
            'recipe_id' => $recipeId,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Recipe added to favorites',
        ], 201);
    }

    public function destroy(Request $request, int $recipeId): JsonResponse
    {
        $user = $this->resolveUser($request);
        $user->favoriteRecipes()->where('recipe_id', $recipeId)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Recipe removed from favorites',
        ]);
    }
}
