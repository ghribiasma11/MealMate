<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Ingredient extends Model
{
    protected $fillable = [
        'name',
        'emoji',
        'category',
        'is_main',
        'is_critical',
    ];

    protected $casts = [
        'is_main' => 'boolean',
        'is_critical' => 'boolean',
    ];

    public function recipes(): BelongsToMany
    {
        return $this->belongsToMany(Recipe::class, 'recipe_ingredients')
            ->withPivot('quantity', 'is_main', 'is_critical')
            ->withTimestamps();
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_ingredients')
            ->withPivot('expiry_date')
            ->withTimestamps();
    }

    public function userIngredients(): HasMany
    {
        return $this->hasMany(UserIngredient::class);
    }

    public function allergies(): HasMany
    {
        return $this->hasMany(Allergy::class);
    }
}
