<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\AppDataController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\IngredientController;
use App\Http\Controllers\MealPlanController;
use App\Http\Controllers\RecipeController;
use App\Http\Controllers\ShoppingController;
use App\Http\Controllers\TranslationController;
use App\Http\Controllers\UserIngredientController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| FlavorCraft API Routes
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // ── Auth (public) ────────────────────────────────────────────────────
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login',    [AuthController::class, 'login']);
    Route::get('/ingredients', [IngredientController::class, 'index']);
    Route::get('/recipes',       [RecipeController::class, 'index']);
    Route::get('/recipes/match', [RecipeController::class, 'match']);
    Route::get('/recipes/{id}',  [RecipeController::class, 'show']);
    Route::get('/app/home', [AppDataController::class, 'home']);
    Route::post('/app/home/ingredients/by-name', [IngredientController::class, 'addUserIngredientByName']);
    Route::delete('/app/home/ingredients/{id}', [IngredientController::class, 'removeUserIngredient']);
    Route::get('/app/favorites', [FavoriteController::class, 'index']);
    Route::post('/app/favorites/{recipeId}', [FavoriteController::class, 'store']);
    Route::delete('/app/favorites/{recipeId}', [FavoriteController::class, 'destroy']);
    Route::get('/app/profile', [AppDataController::class, 'profile']);
    Route::patch('/app/profile/settings', [AppDataController::class, 'updateSettings']);
    Route::post('/app/profile/allergies', [IngredientController::class, 'addAllergy']);
    Route::delete('/app/profile/allergies/{id}', [IngredientController::class, 'removeAllergy']);
    Route::get('/app/search/bootstrap', [AppDataController::class, 'searchBootstrap']);
    Route::get('/app/search', [AppDataController::class, 'search']);
    Route::get('/app/meal-planner', [MealPlanController::class, 'index']);
    Route::post('/app/meal-planner/slots', [MealPlanController::class, 'store']);
    Route::delete('/app/meal-planner/slots', [MealPlanController::class, 'destroy']);
    Route::get('/app/shopping-list', [ShoppingController::class, 'getList']);
    Route::post('/app/shopping-list/generate', [ShoppingController::class, 'generate']);
    Route::post('/app/shopping-list/items', [ShoppingController::class, 'addItem']);
    Route::patch('/app/shopping-list/items/{id}', [ShoppingController::class, 'updateItem']);
    Route::delete('/app/shopping-list/items/{id}', [ShoppingController::class, 'deleteItem']);
    Route::post('/translations', [TranslationController::class, 'translate']);

    // ── Protected routes ─────────────────────────────────────────────────
    Route::middleware('auth:sanctum')->group(function () {

        // Auth
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me',      [AuthController::class, 'me']);

        // ── Ingredients (global catalogue) ────────────────────────────────
        Route::get('/ingredients', [IngredientController::class, 'index']);

        // ── User fridge (my ingredients) ─────────────────────────────────
        Route::get('/user/ingredients',            [IngredientController::class, 'getUserIngredients']);
        Route::post('/user/ingredients',           [IngredientController::class, 'addUserIngredient']);
        Route::post('/user/ingredients/by-name',   [IngredientController::class, 'addUserIngredientByName']);
        Route::delete('/user/ingredients/{id}',    [IngredientController::class, 'removeUserIngredient']);

        // Fridge reminders
        Route::get('/user/ingredients/expiring',          [UserIngredientController::class, 'expiringIngredients']);
        Route::patch('/user/ingredients/{id}/expiry',     [UserIngredientController::class, 'updateExpiry']);

        // ── Allergies ─────────────────────────────────────────────────────
        Route::get('/user/allergies',         [IngredientController::class, 'getUserAllergies']);
        Route::post('/user/allergies',        [IngredientController::class, 'addAllergy']);
        Route::delete('/user/allergies/{id}', [IngredientController::class, 'removeAllergy']);

        // ── Recipes ───────────────────────────────────────────────────────

        // ── Shopping ──────────────────────────────────────────────────────
        Route::post('/shopping/generate',        [ShoppingController::class, 'generate']);
        Route::get('/shopping/list',             [ShoppingController::class, 'getList']);
        Route::post('/shopping/items',           [ShoppingController::class, 'addItem']);
        Route::patch('/shopping/item/{id}',      [ShoppingController::class, 'updateItem']);
        Route::delete('/shopping/item/{id}',     [ShoppingController::class, 'deleteItem']);
        Route::delete('/shopping/clear',         [ShoppingController::class, 'clearList']);
    });
});
