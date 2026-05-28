<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserIngredientController extends Controller
{
    public function expiringIngredients(Request $request): JsonResponse
    {
        $user = $request->user();
        $days = (int) ($request->query('days', 3));

        $expiring = $user->userIngredients()
            ->with('ingredient')
            ->whereNotNull('expiry_date')
            ->whereDate('expiry_date', '<=', now()->addDays($days))
            ->whereDate('expiry_date', '>=', now())
            ->get()
            ->map(function ($ui) {
                $data = $ui->ingredient->toArray();
                $data['expiry_date']       = $ui->expiry_date;
                $data['days_until_expiry'] = now()->diffInDays($ui->expiry_date, false);
                return $data;
            });

        return response()->json([
            'success' => true,
            'data'    => $expiring,
            'message' => $expiring->count() > 0
                ? "You have {$expiring->count()} ingredient(s) expiring soon!"
                : 'No ingredients expiring soon.',
        ]);
    }

    public function updateExpiry(Request $request, int $ingredientId): JsonResponse
    {
        $validated = $request->validate([
            'expiry_date' => 'required|date',
        ]);

        $user = $request->user();

        $ui = $user->userIngredients()->where('ingredient_id', $ingredientId)->firstOrFail();
        $ui->update(['expiry_date' => $validated['expiry_date']]);

        return response()->json([
            'success' => true,
            'message' => 'Expiry date updated',
            'data'    => $ui->load('ingredient'),
        ]);
    }
}
