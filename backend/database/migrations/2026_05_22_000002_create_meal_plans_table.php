<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('meal_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('recipe_id')->constrained()->cascadeOnDelete();
            $table->date('planned_date');
            $table->string('meal_type');
            $table->timestamps();

            $table->unique(['user_id', 'planned_date', 'meal_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('meal_plans');
    }
};
