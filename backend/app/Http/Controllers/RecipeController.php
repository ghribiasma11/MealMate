<?php

namespace App\Http\Controllers;

use App\Models\Recipe;
use App\Models\Ingredient;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RecipeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Recipe::with('ingredients');

        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        if ($request->has('difficulty')) {
            $query->where('difficulty', $request->difficulty);
        }

        if ($request->has('max_time')) {
            $query->where('time', '<=', (int) $request->max_time);
        }

        if ($request->boolean('vegetarian')) {
            $query->where('is_vegetarian', true);
        }

        if ($request->boolean('gluten_free')) {
            $query->where('is_gluten_free', true);
        }

        if ($request->boolean('lactose_free')) {
            $query->where('is_lactose_free', true);
        }

        $recipes = $query->get()->map(fn ($r) => $this->formatRecipe($r));

        return response()->json([
            'success' => true,
            'data'    => $recipes,
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $recipe = Recipe::with('ingredients')->findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $this->formatRecipe($recipe),
        ]);
    }

    public function match(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'ingredients'   => 'required|array|min:1',
            'ingredients.*' => 'string',
            'max_time'      => 'nullable|integer|min:1',
            'vegetarian'    => 'nullable|boolean',
            'gluten_free'   => 'nullable|boolean',
            'lactose_free'  => 'nullable|boolean',
        ]);

        $user = $request->user();

        $userIngredientNames = collect($validated['ingredients'])
            ->map(fn ($name) => strtolower(trim($name)));

        $allergyIngredientIds = $user
            ? $user->allergies()->pluck('ingredient_id')->toArray()
            : [];

        $query = Recipe::with('ingredients');

        if (! empty($validated['max_time'])) {
            $query->where('time', '<=', $validated['max_time']);
        }
        if (! empty($validated['vegetarian'])) {
            $query->where('is_vegetarian', true);
        }
        if (! empty($validated['gluten_free'])) {
            $query->where('is_gluten_free', true);
        }
        if (! empty($validated['lactose_free'])) {
            $query->where('is_lactose_free', true);
        }

        $recipes = $query->get();

        $scored = $recipes->map(function (Recipe $recipe) use ($userIngredientNames, $allergyIngredientIds) {
            $recipeIngredients = $recipe->ingredients;

            foreach ($recipeIngredients as $ingredient) {
                if (in_array($ingredient->id, $allergyIngredientIds)) {
                    return null;
                }
            }

            $total = $recipeIngredients->count();
            if ($total === 0) return null;

            $matched = $recipeIngredients->filter(function ($ingredient) use ($userIngredientNames) {
                return $userIngredientNames->contains(strtolower($ingredient->name));
            });

            $missing = $recipeIngredients->filter(function ($ingredient) use ($userIngredientNames) {
                return ! $userIngredientNames->contains(strtolower($ingredient->name));
            });

            $matchedCount = $matched->count();
            $score = $matchedCount / $total;

            $hasMainIngredient = $matched->contains(fn ($i) => $i->pivot->is_main);
            $missingCritical = $missing->contains(fn ($i) => $i->pivot->is_critical);

            if ($hasMainIngredient) {
                $score += 0.10;
            }
            if ($missingCritical) {
                $score -= 0.20;
            }
            if ($recipe->time <= 15) {
                $score += 0.05;
            }

            $score = max(0, min(1, $score));

            $formatted = $this->formatRecipe($recipe);
            $formatted['match_score']       = (int) round($score * 100);
            $formatted['matched_count']     = $matchedCount;
            $formatted['total_ingredients'] = $total;
            $formatted['ingredients_have']  = $matched->pluck('name')->values();
            $formatted['ingredients_missing'] = $missing->pluck('name')->values();

            return $formatted;
        })
        ->filter()
        ->sortByDesc('match_score')
        ->take(10)
        ->values();

        return response()->json([
            'success' => true,
            'data'    => $scored,
        ]);
    }

    private function formatRecipe(Recipe $recipe): array
    {
        return [
            'id'             => $recipe->id,
            'name'           => $recipe->name,
            'title'          => $recipe->name,
            'image'          => $recipe->image,
            'description'    => $recipe->description,
            'instructions'   => $recipe->instructions,
            'time'           => $recipe->time,
            'difficulty'     => $recipe->difficulty,
            'category'       => $recipe->category,
            'servings'       => $recipe->servings,
            'is_vegetarian'  => $recipe->is_vegetarian,
            'is_gluten_free' => $recipe->is_gluten_free,
            'is_lactose_free'=> $recipe->is_lactose_free,
            'ingredients'    => $recipe->ingredients->map(fn ($i) => [
                'id'          => $i->id,
                'name'        => $i->name,
                'emoji'       => $i->emoji,
                'category'    => $i->category,
                'quantity'    => $i->pivot->quantity,
                'is_main'     => $i->pivot->is_main,
                'is_critical' => $i->pivot->is_critical,
            ]),
        ];
    }
}
