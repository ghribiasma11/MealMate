<?php

namespace App\Http\Controllers;

use App\Models\Ingredient;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class IngredientController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Ingredient::query();

        if ($request->has('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        $ingredients = $query->orderBy('name')->get();

        return response()->json([
            'success' => true,
            'data'    => $ingredients,
        ]);
    }

    public function getUserIngredients(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);

        $ingredients = $user->userIngredients()
            ->with('ingredient')
            ->get()
            ->map(function ($ui) {
                $data = $ui->ingredient->toArray();
                $data['expiry_date'] = $ui->expiry_date;
                $data['user_ingredient_id'] = $ui->id;

                if ($data['expiry_date']) {
                    $daysUntilExpiry = now()->diffInDays($data['expiry_date'], false);
                    $data['expires_soon'] = $daysUntilExpiry <= 2 && $daysUntilExpiry >= 0;
                    $data['is_expired'] = $daysUntilExpiry < 0;
                } else {
                    $data['expires_soon'] = false;
                    $data['is_expired'] = false;
                }

                return $data;
            });

        return response()->json([
            'success' => true,
            'data'    => $ingredients,
        ]);
    }

    public function addUserIngredient(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'ingredient_id' => 'required|exists:ingredients,id',
            'expiry_date'   => 'nullable|date',
        ]);

        $user = $this->resolveUser($request);

        $userIngredient = $user->userIngredients()->updateOrCreate(
            ['ingredient_id' => $validated['ingredient_id']],
            ['expiry_date'   => $validated['expiry_date'] ?? null]
        );

        $userIngredient->load('ingredient');

        return response()->json([
            'success' => true,
            'message' => 'Ingredient added to your fridge',
            'data'    => $userIngredient,
        ], 201);
    }

    public function addUserIngredientByName(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'        => 'required|string|max:255',
            'expiry_date' => 'nullable|date',
        ]);

        $ingredient = Ingredient::firstOrCreate(
            ['name' => ucfirst(strtolower(trim($validated['name'])))],
            ['category' => 'other', 'emoji' => '🥘']
        );

        $user = $this->resolveUser($request);
        $userIngredient = $user->userIngredients()->updateOrCreate(
            ['ingredient_id' => $ingredient->id],
            ['expiry_date'   => $validated['expiry_date'] ?? null]
        );

        $userIngredient->load('ingredient');

        return response()->json([
            'success' => true,
            'message' => 'Ingredient added to your fridge',
            'data'    => $userIngredient,
        ], 201);
    }

    public function removeUserIngredient(Request $request, int $ingredientId): JsonResponse
    {
        $user = $this->resolveUser($request);

        $deleted = $user->userIngredients()
            ->where('ingredient_id', $ingredientId)
            ->delete();

        if (! $deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Ingredient not found in your fridge',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Ingredient removed from your fridge',
        ]);
    }

    public function getUserAllergies(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);

        $allergies = $user->allergies()->with('ingredient')->get()
            ->map(fn ($a) => $a->ingredient);

        return response()->json([
            'success' => true,
            'data'    => $allergies,
        ]);
    }

    public function addAllergy(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'ingredient_id' => 'required|exists:ingredients,id',
        ]);

        $user = $this->resolveUser($request);

        $user->allergies()->firstOrCreate([
            'ingredient_id' => $validated['ingredient_id'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Allergy added',
        ], 201);
    }

    public function removeAllergy(Request $request, int $ingredientId): JsonResponse
    {
        $user = $this->resolveUser($request);

        $user->allergies()->where('ingredient_id', $ingredientId)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Allergy removed',
        ]);
    }
}
