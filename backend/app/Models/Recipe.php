<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Recipe extends Model
{
    protected $fillable = [
        'name',
        'image',
        'description',
        'instructions',
        'time',
        'difficulty',
        'category',
        'servings',
        'is_vegetarian',
        'is_gluten_free',
        'is_lactose_free',
    ];

    protected $casts = [
        'is_vegetarian' => 'boolean',
        'is_gluten_free' => 'boolean',
        'is_lactose_free' => 'boolean',
        'instructions' => 'array',
    ];

    public function ingredients(): BelongsToMany
    {
        return $this->belongsToMany(Ingredient::class, 'recipe_ingredients')
            ->withPivot('quantity', 'is_main', 'is_critical')
            ->withTimestamps();
    }

    public function recipeIngredients(): HasMany
    {
        return $this->hasMany(RecipeIngredient::class);
    }
}
