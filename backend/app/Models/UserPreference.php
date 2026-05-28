<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserPreference extends Model
{
    protected $fillable = [
        'user_id',
        'notifications_enabled',
        'dark_mode',
        'selected_language',
        'selected_budget',
        'diet_preferences',
    ];

    protected $casts = [
        'notifications_enabled' => 'boolean',
        'dark_mode' => 'boolean',
        'diet_preferences' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
