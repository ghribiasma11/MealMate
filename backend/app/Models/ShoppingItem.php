<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ShoppingItem extends Model
{
    protected $fillable = [
        'shopping_list_id',
        'ingredient_name',
        'quantity',
        'category',
        'is_checked',
    ];

    protected $casts = [
        'is_checked' => 'boolean',
    ];

    public function shoppingList(): BelongsTo
    {
        return $this->belongsTo(ShoppingList::class);
    }
}
