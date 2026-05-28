<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recipes', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('image')->nullable();
            $table->text('description')->nullable();
            $table->longText('instructions');
            $table->integer('time')->default(30);
            $table->string('difficulty')->default('Easy');
            $table->string('category')->default('Dinner');
            $table->integer('servings')->default(2);
            $table->boolean('is_vegetarian')->default(false);
            $table->boolean('is_gluten_free')->default(false);
            $table->boolean('is_lactose_free')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recipes');
    }
};
