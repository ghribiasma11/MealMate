<?php

namespace App\Http\Controllers;

use App\Models\ShoppingList;
use App\Models\ShoppingItem;
use App\Models\Recipe;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ShoppingController extends Controller
{
    private const CATEGORIES = [
        'vegetables' => ['tomato', 'onion', 'garlic', 'carrot', 'spinach', 'lettuce', 'pepper', 'zucchini', 'broccoli', 'mushroom', 'celery', 'leek', 'cabbage', 'basil', 'parsley'],
        'meat'       => ['chicken', 'beef', 'pork', 'lamb', 'turkey', 'bacon', 'sausage', 'meat', 'ground', 'mince'],
        'dairy'      => ['milk', 'cheese', 'butter', 'cream', 'yogurt', 'egg', 'eggs', 'mozzarella', 'parmesan'],
        'seafood'    => ['fish', 'salmon', 'tuna', 'shrimp', 'prawn', 'crab', 'lobster', 'cod', 'tilapia'],
        'grains'     => ['rice', 'pasta', 'flour', 'bread', 'oats', 'quinoa', 'noodle', 'couscous', 'wheat'],
        'pantry'     => ['oil', 'olive', 'salt', 'pepper', 'sugar', 'honey', 'vinegar', 'sauce', 'paste', 'stock', 'broth', 'can', 'bean', 'lentil'],
        'fruits'     => ['apple', 'banana', 'lemon', 'orange', 'lime', 'berry', 'tomato', 'avocado'],
        'spices'     => ['cumin', 'paprika', 'turmeric', 'cinnamon', 'oregano', 'thyme', 'rosemary', 'ginger', 'chili', 'curry'],
    ];

    private function categorize(string $name): string
    {
        $lower = strtolower($name);
        foreach (self::CATEGORIES as $category => $keywords) {
            foreach ($keywords as $keyword) {
                if (str_contains($lower, $keyword)) {
                    return $category;
                }
            }
        }
        return 'other';
    }

    public function getList(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);

        $list = $user->shoppingLists()->with('items')->latest()->first();

        if (! $list) {
            return response()->json([
                'success' => true,
                'data'    => null,
                'message' => 'No shopping list found',
            ]);
        }

        $grouped = $list->items->groupBy('category')->map(function ($items, $category) {
            return [
                'category' => $category,
                'items'    => $items->values(),
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data'    => [
                'id'      => $list->id,
                'name'    => $list->name,
                'grouped' => $grouped,
                'items'   => $list->items->values(),
                'total'   => $list->items->count(),
                'checked' => $list->items->where('is_checked', true)->count(),
            ],
        ]);
    }

    public function generate(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'recipe_ids'         => 'nullable|array',
            'recipe_ids.*'       => 'integer|exists:recipes,id',
            'missing_ingredients'=> 'nullable|array',
            'missing_ingredients.*' => 'string',
        ]);

        $user = $this->resolveUser($request);

        $user->shoppingLists()->delete();

        $list = $user->shoppingLists()->create([
            'name' => 'Shopping List — ' . now()->format('M d, Y'),
        ]);

        $itemsToCreate = collect();

        if (! empty($validated['recipe_ids'])) {
            $recipes = Recipe::with('ingredients')->whereIn('id', $validated['recipe_ids'])->get();
            foreach ($recipes as $recipe) {
                foreach ($recipe->ingredients as $ingredient) {
                    $itemsToCreate->push([
                        'ingredient_name' => $ingredient->name,
                        'quantity'        => $ingredient->pivot->quantity ?? '1',
                        'category'        => $this->categorize($ingredient->name),
                        'is_checked'      => false,
                    ]);
                }
            }
        }

        if (! empty($validated['missing_ingredients'])) {
            foreach ($validated['missing_ingredients'] as $name) {
                $itemsToCreate->push([
                    'ingredient_name' => ucfirst(trim($name)),
                    'quantity'        => null,
                    'category'        => $this->categorize($name),
                    'is_checked'      => false,
                ]);
            }
        }

        $unique = $itemsToCreate->unique('ingredient_name')->values();

        foreach ($unique as $item) {
            $list->items()->create($item);
        }

        $list->load('items');

        $grouped = $list->items->groupBy('category')->map(function ($items, $category) {
            return [
                'category' => $category,
                'items'    => $items->values(),
            ];
        })->values();

        return response()->json([
            'success' => true,
            'message' => 'Shopping list generated',
            'data'    => [
                'id'      => $list->id,
                'name'    => $list->name,
                'grouped' => $grouped,
                'items'   => $list->items->values(),
                'total'   => $list->items->count(),
            ],
        ], 201);
    }

    public function updateItem(Request $request, int $itemId): JsonResponse
    {
        $validated = $request->validate([
            'is_checked' => 'required|boolean',
        ]);

        $user = $this->resolveUser($request);

        $item = ShoppingItem::whereHas('shoppingList', function ($q) use ($user) {
            $q->where('user_id', $user->id);
        })->findOrFail($itemId);

        $item->update(['is_checked' => $validated['is_checked']]);

        return response()->json([
            'success' => true,
            'message' => 'Item updated',
            'data'    => $item,
        ]);
    }

    public function addItem(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'ingredient_name' => 'required|string|max:255',
            'quantity'        => 'nullable|string',
        ]);

        $user = $this->resolveUser($request);

        $list = $user->shoppingLists()->latest()->first();

        if (! $list) {
            $list = $user->shoppingLists()->create([
                'name' => 'Shopping List — ' . now()->format('M d, Y'),
            ]);
        }

        $item = $list->items()->create([
            'ingredient_name' => ucfirst(trim($validated['ingredient_name'])),
            'quantity'        => $validated['quantity'] ?? null,
            'category'        => $this->categorize($validated['ingredient_name']),
            'is_checked'      => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Item added',
            'data'    => $item,
        ], 201);
    }

    public function deleteItem(Request $request, int $itemId): JsonResponse
    {
        $user = $this->resolveUser($request);

        $item = ShoppingItem::whereHas('shoppingList', function ($q) use ($user) {
            $q->where('user_id', $user->id);
        })->findOrFail($itemId);

        $item->delete();

        return response()->json([
            'success' => true,
            'message' => 'Item deleted',
        ]);
    }

    public function clearList(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);
        $user->shoppingLists()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Shopping list cleared',
        ]);
    }
}
