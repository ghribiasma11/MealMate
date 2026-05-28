<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_ingredients', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('ingredient_id')->constrained()->onDelete('cascade');
            $table->date('expiry_date')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'ingredient_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_ingredients');
    }
};
