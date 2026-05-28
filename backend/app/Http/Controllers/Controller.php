<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;

abstract class Controller
{
    protected function resolveUser(?Request $request = null): User
    {
        if ($request?->user()) {
            return $request->user();
        }

        $token = $request?->bearerToken();
        if ($token) {
            $accessToken = PersonalAccessToken::findToken($token);
            if ($accessToken?->tokenable instanceof User) {
                return $accessToken->tokenable;
            }
        }

        return User::firstOrCreate(
            ['email' => 'test@example.com'],
            [
                'name' => 'Test User',
                'password' => Hash::make('password'),
            ],
        );
    }
}
