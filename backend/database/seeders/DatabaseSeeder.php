<?php

namespace Database\Seeders;

use App\Models\Ingredient;
use App\Models\Recipe;
use App\Models\ShoppingList;
use App\Models\User;
use App\Models\UserPreference;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ── Demo user ──────────────────────────────────────────────────────
        $user = User::firstOrCreate(['email' => 'test@example.com'], [
            'name'     => 'Test User',
            'password' => Hash::make('password'),
        ]);

        // ── Ingredients ───────────────────────────────────────────────────
        $ingredients = [
            ['name' => 'Eggs',           'emoji' => '🥚', 'category' => 'dairy',      'is_main' => true,  'is_critical' => true],
            ['name' => 'Milk',           'emoji' => '🥛', 'category' => 'dairy',      'is_main' => false, 'is_critical' => false],
            ['name' => 'Butter',         'emoji' => '🧈', 'category' => 'dairy',      'is_main' => false, 'is_critical' => false],
            ['name' => 'Cheese',         'emoji' => '🧀', 'category' => 'dairy',      'is_main' => false, 'is_critical' => false],
            ['name' => 'Parmesan',       'emoji' => '🧀', 'category' => 'dairy',      'is_main' => false, 'is_critical' => false],
            ['name' => 'Greek Yogurt',   'emoji' => '🥣', 'category' => 'dairy',      'is_main' => false, 'is_critical' => false],
            ['name' => 'Chicken',        'emoji' => '🍗', 'category' => 'meat',       'is_main' => true,  'is_critical' => true],
            ['name' => 'Ground Beef',    'emoji' => '🥩', 'category' => 'meat',       'is_main' => true,  'is_critical' => true],
            ['name' => 'Bacon',          'emoji' => '🥓', 'category' => 'meat',       'is_main' => true,  'is_critical' => false],
            ['name' => 'Salmon',         'emoji' => '🐟', 'category' => 'seafood',    'is_main' => true,  'is_critical' => true],
            ['name' => 'Tuna',           'emoji' => '🐟', 'category' => 'seafood',    'is_main' => true,  'is_critical' => false],
            ['name' => 'Tomato',         'emoji' => '🍅', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Onion',          'emoji' => '🧅', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Garlic',         'emoji' => '🧄', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Carrot',         'emoji' => '🥕', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Spinach',        'emoji' => '🥬', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Bell Pepper',    'emoji' => '🫑', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Mushroom',       'emoji' => '🍄', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Broccoli',       'emoji' => '🥦', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Zucchini',       'emoji' => '🥒', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Potato',         'emoji' => '🥔', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Lettuce',        'emoji' => '🥗', 'category' => 'vegetables', 'is_main' => false, 'is_critical' => false],
            ['name' => 'Avocado',        'emoji' => '🥑', 'category' => 'fruits',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Lemon',          'emoji' => '🍋', 'category' => 'fruits',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Pasta',          'emoji' => '🍝', 'category' => 'grains',     'is_main' => true,  'is_critical' => true],
            ['name' => 'Rice',           'emoji' => '🍚', 'category' => 'grains',     'is_main' => true,  'is_critical' => true],
            ['name' => 'Flour',          'emoji' => '🌾', 'category' => 'grains',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Bread',          'emoji' => '🍞', 'category' => 'grains',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Oats',           'emoji' => '🌾', 'category' => 'grains',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Olive Oil',      'emoji' => '🫙', 'category' => 'pantry',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Salt',           'emoji' => '🧂', 'category' => 'spices',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Black Pepper',   'emoji' => '🌶', 'category' => 'spices',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Cumin',          'emoji' => '🌶', 'category' => 'spices',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Paprika',        'emoji' => '🌶', 'category' => 'spices',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Basil',          'emoji' => '🌿', 'category' => 'spices',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Oregano',        'emoji' => '🌿', 'category' => 'spices',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Soy Sauce',      'emoji' => '🫙', 'category' => 'pantry',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Tomato Sauce',   'emoji' => '🍅', 'category' => 'pantry',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Chicken Stock',  'emoji' => '🫙', 'category' => 'pantry',     'is_main' => false, 'is_critical' => false],
            ['name' => 'Heavy Cream',    'emoji' => '🥛', 'category' => 'dairy',      'is_main' => false, 'is_critical' => false],
        ];

        foreach ($ingredients as $data) {
            Ingredient::firstOrCreate(['name' => $data['name']], $data);
        }

        // ── Recipes ───────────────────────────────────────────────────────
        $recipes = [
            [
                'name'        => 'Scrambled Eggs with Tomato',
                'image'       => 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?w=600&h=400&fit=crop',
                'description' => 'A quick and delicious breakfast made with fresh eggs and ripe tomatoes.',
                'instructions' => json_encode([
                    'Crack 3 eggs into a bowl and whisk until combined.',
                    'Dice the tomato into small cubes and set aside.',
                    'Heat butter in a non-stick pan over medium heat.',
                    'Pour in the eggs and stir gently with a spatula.',
                    'Add the diced tomato when eggs are half-cooked.',
                    'Season with salt and pepper. Serve immediately.',
                ]),
                'time'       => 10,
                'difficulty' => 'Easy',
                'category'   => 'Breakfast',
                'servings'   => 2,
                'is_vegetarian' => true,
                'is_gluten_free' => true,
                'is_lactose_free' => false,
                'ingredients' => [
                    ['name' => 'Eggs',         'quantity' => '3',      'is_main' => true,  'is_critical' => true],
                    ['name' => 'Tomato',       'quantity' => '1 large','is_main' => false, 'is_critical' => false],
                    ['name' => 'Butter',       'quantity' => '1 tbsp', 'is_main' => false, 'is_critical' => false],
                    ['name' => 'Salt',         'quantity' => 'to taste','is_main' => false,'is_critical' => false],
                    ['name' => 'Black Pepper', 'quantity' => 'to taste','is_main' => false,'is_critical' => false],
                    ['name' => 'Basil',        'quantity' => 'a few leaves','is_main' => false,'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Chicken Tomato Pasta',
                'image'       => 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=600&h=400&fit=crop',
                'description' => 'A classic pasta dish with tender chicken in a rich tomato sauce.',
                'instructions' => json_encode([
                    'Cook pasta according to package instructions until al dente.',
                    'Season chicken with salt, pepper and paprika.',
                    'Heat olive oil in a pan and cook chicken until golden, about 6 minutes per side.',
                    'Remove chicken, rest 5 minutes, then slice.',
                    'In same pan, sauté garlic and onion 3 minutes.',
                    'Add tomato sauce, simmer 10 minutes.',
                    'Toss pasta in sauce, top with sliced chicken and parmesan.',
                ]),
                'time'       => 25,
                'difficulty' => 'Medium',
                'category'   => 'Dinner',
                'servings'   => 4,
                'is_vegetarian' => false,
                'is_gluten_free' => false,
                'is_lactose_free' => false,
                'ingredients' => [
                    ['name' => 'Pasta',        'quantity' => '400g',    'is_main' => true,  'is_critical' => true],
                    ['name' => 'Chicken',      'quantity' => '500g',    'is_main' => true,  'is_critical' => true],
                    ['name' => 'Tomato Sauce', 'quantity' => '400ml',   'is_main' => false, 'is_critical' => false],
                    ['name' => 'Garlic',       'quantity' => '3 cloves','is_main' => false, 'is_critical' => false],
                    ['name' => 'Onion',        'quantity' => '1 medium','is_main' => false, 'is_critical' => true],
                    ['name' => 'Olive Oil',    'quantity' => '2 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Parmesan',     'quantity' => '50g',     'is_main' => false, 'is_critical' => false],
                    ['name' => 'Paprika',      'quantity' => '1 tsp',   'is_main' => false, 'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Tomato Omelette',
                'image'       => 'https://images.pexels.com/photos/824635/pexels-photo-824635.jpeg?w=600&h=400&fit=crop',
                'description' => 'A fluffy golden omelette filled with fresh tomatoes and herbs.',
                'instructions' => json_encode([
                    'Whisk 3 eggs with a pinch of salt.',
                    'Dice tomato and set aside.',
                    'Melt butter in a non-stick pan over medium heat.',
                    'Pour egg mixture and tilt pan to spread evenly.',
                    'Add tomato on one half when top is just set.',
                    'Fold omelette and slide onto plate.',
                    'Season with pepper and basil.',
                ]),
                'time'       => 15,
                'difficulty' => 'Easy',
                'category'   => 'Breakfast',
                'servings'   => 1,
                'is_vegetarian' => true,
                'is_gluten_free' => true,
                'is_lactose_free' => false,
                'ingredients' => [
                    ['name' => 'Eggs',         'quantity' => '3',       'is_main' => true,  'is_critical' => true],
                    ['name' => 'Tomato',       'quantity' => '1 medium','is_main' => false, 'is_critical' => false],
                    ['name' => 'Butter',       'quantity' => '1 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Salt',         'quantity' => 'pinch',   'is_main' => false, 'is_critical' => false],
                    ['name' => 'Basil',        'quantity' => 'a few leaves','is_main' => false,'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Grilled Chicken Salad',
                'image'       => 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&h=400&fit=crop',
                'description' => 'A healthy and satisfying salad with juicy grilled chicken.',
                'instructions' => json_encode([
                    'Season chicken with salt, pepper, and olive oil.',
                    'Grill or pan-fry chicken 6-8 minutes per side until cooked through.',
                    'Rest 5 minutes then slice.',
                    'Wash and tear lettuce into a large bowl.',
                    'Add sliced tomato and bell pepper.',
                    'Top with sliced chicken.',
                    'Drizzle with olive oil and lemon juice.',
                ]),
                'time'       => 20,
                'difficulty' => 'Easy',
                'category'   => 'Lunch',
                'servings'   => 2,
                'is_vegetarian' => false,
                'is_gluten_free' => true,
                'is_lactose_free' => true,
                'ingredients' => [
                    ['name' => 'Chicken',     'quantity' => '300g',    'is_main' => true,  'is_critical' => true],
                    ['name' => 'Lettuce',     'quantity' => '1 head',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Tomato',      'quantity' => '2 medium','is_main' => false, 'is_critical' => false],
                    ['name' => 'Bell Pepper', 'quantity' => '1',       'is_main' => false, 'is_critical' => false],
                    ['name' => 'Olive Oil',   'quantity' => '2 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Lemon',       'quantity' => '1',       'is_main' => false, 'is_critical' => false],
                    ['name' => 'Salt',        'quantity' => 'to taste','is_main' => false, 'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Creamy Chicken Soup',
                'image'       => 'https://images.pexels.com/photos/539451/pexels-photo-539451.jpeg?w=600&h=400&fit=crop',
                'description' => 'A warming and creamy chicken soup perfect for cold days.',
                'instructions' => json_encode([
                    'Sauté diced onion and garlic in butter until soft.',
                    'Add diced chicken and cook until browned.',
                    'Pour in chicken stock and bring to a boil.',
                    'Add diced carrot and potato.',
                    'Simmer 20 minutes until vegetables are tender.',
                    'Stir in heavy cream and season.',
                    'Serve hot with bread.',
                ]),
                'time'       => 40,
                'difficulty' => 'Medium',
                'category'   => 'Dinner',
                'servings'   => 4,
                'is_vegetarian' => false,
                'is_gluten_free' => false,
                'is_lactose_free' => false,
                'ingredients' => [
                    ['name' => 'Chicken',       'quantity' => '400g',    'is_main' => true,  'is_critical' => true],
                    ['name' => 'Chicken Stock', 'quantity' => '1L',      'is_main' => false, 'is_critical' => true],
                    ['name' => 'Heavy Cream',   'quantity' => '200ml',   'is_main' => false, 'is_critical' => false],
                    ['name' => 'Onion',         'quantity' => '1 large', 'is_main' => false, 'is_critical' => false],
                    ['name' => 'Garlic',        'quantity' => '3 cloves','is_main' => false, 'is_critical' => false],
                    ['name' => 'Carrot',        'quantity' => '2',       'is_main' => false, 'is_critical' => false],
                    ['name' => 'Potato',        'quantity' => '2 medium','is_main' => false, 'is_critical' => false],
                    ['name' => 'Butter',        'quantity' => '2 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Bread',         'quantity' => 'to serve','is_main' => false, 'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Egg Fried Rice',
                'image'       => 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600&h=400&fit=crop',
                'description' => 'A quick and tasty fried rice dish — perfect for using up leftover rice.',
                'instructions' => json_encode([
                    'Cook rice and let it cool (use day-old rice if possible).',
                    'Scramble eggs in a lightly oiled pan, set aside.',
                    'Stir-fry garlic in oil for 30 seconds.',
                    'Add rice and stir-fry on high heat 3-4 minutes.',
                    'Add soy sauce and mix well.',
                    'Fold in scrambled eggs and spring onion.',
                    'Season and serve immediately.',
                ]),
                'time'       => 15,
                'difficulty' => 'Easy',
                'category'   => 'Lunch',
                'servings'   => 2,
                'is_vegetarian' => true,
                'is_gluten_free' => false,
                'is_lactose_free' => true,
                'ingredients' => [
                    ['name' => 'Rice',      'quantity' => '2 cups',  'is_main' => true,  'is_critical' => true],
                    ['name' => 'Eggs',      'quantity' => '2',       'is_main' => true,  'is_critical' => true],
                    ['name' => 'Soy Sauce', 'quantity' => '2 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Garlic',    'quantity' => '2 cloves','is_main' => false, 'is_critical' => false],
                    ['name' => 'Olive Oil', 'quantity' => '1 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Salt',      'quantity' => 'to taste','is_main' => false, 'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Spaghetti Bolognese',
                'image'       => 'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg?w=600&h=400&fit=crop',
                'description' => 'The classic Italian meat sauce slowly simmered to perfection.',
                'instructions' => json_encode([
                    'Cook pasta in salted boiling water until al dente.',
                    'Sauté onion, garlic and carrot in olive oil 5 minutes.',
                    'Add ground beef and brown well, breaking it apart.',
                    'Pour in tomato sauce and season with oregano, salt, pepper.',
                    'Simmer 20 minutes on low heat.',
                    'Toss pasta with sauce and serve with parmesan.',
                ]),
                'time'       => 35,
                'difficulty' => 'Medium',
                'category'   => 'Dinner',
                'servings'   => 4,
                'is_vegetarian' => false,
                'is_gluten_free' => false,
                'is_lactose_free' => false,
                'ingredients' => [
                    ['name' => 'Pasta',        'quantity' => '400g',    'is_main' => true,  'is_critical' => true],
                    ['name' => 'Ground Beef',  'quantity' => '500g',    'is_main' => true,  'is_critical' => true],
                    ['name' => 'Tomato Sauce', 'quantity' => '400ml',   'is_main' => false, 'is_critical' => true],
                    ['name' => 'Onion',        'quantity' => '1',       'is_main' => false, 'is_critical' => true],
                    ['name' => 'Garlic',       'quantity' => '3 cloves','is_main' => false, 'is_critical' => false],
                    ['name' => 'Carrot',       'quantity' => '1',       'is_main' => false, 'is_critical' => false],
                    ['name' => 'Olive Oil',    'quantity' => '2 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Oregano',      'quantity' => '1 tsp',   'is_main' => false, 'is_critical' => false],
                    ['name' => 'Parmesan',     'quantity' => '50g',     'is_main' => false, 'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Chicken Stir Fry',
                'image'       => 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600&h=400&fit=crop',
                'description' => 'A colourful and quick stir fry packed with vegetables.',
                'instructions' => json_encode([
                    'Slice chicken into thin strips and season.',
                    'Heat oil in a wok on high heat.',
                    'Cook chicken strips 4-5 minutes until golden.',
                    'Add bell pepper, broccoli and mushroom, stir-fry 3 minutes.',
                    'Add soy sauce and garlic, toss everything together.',
                    'Serve over steamed rice.',
                ]),
                'time'       => 20,
                'difficulty' => 'Medium',
                'category'   => 'Dinner',
                'servings'   => 2,
                'is_vegetarian' => false,
                'is_gluten_free' => false,
                'is_lactose_free' => true,
                'ingredients' => [
                    ['name' => 'Chicken',     'quantity' => '300g',    'is_main' => true,  'is_critical' => true],
                    ['name' => 'Bell Pepper', 'quantity' => '1',       'is_main' => false, 'is_critical' => false],
                    ['name' => 'Broccoli',    'quantity' => '200g',    'is_main' => false, 'is_critical' => false],
                    ['name' => 'Mushroom',    'quantity' => '100g',    'is_main' => false, 'is_critical' => false],
                    ['name' => 'Soy Sauce',   'quantity' => '3 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Garlic',      'quantity' => '2 cloves','is_main' => false, 'is_critical' => false],
                    ['name' => 'Olive Oil',   'quantity' => '2 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Rice',        'quantity' => '1 cup',   'is_main' => false, 'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Avocado Toast with Eggs',
                'image'       => 'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg?w=600&h=400&fit=crop',
                'description' => 'The ultimate quick breakfast — creamy avocado on toast topped with a perfect egg.',
                'instructions' => json_encode([
                    'Toast bread until golden and crisp.',
                    'Mash avocado with lemon juice, salt and pepper.',
                    'Fry or poach an egg to your liking.',
                    'Spread avocado on toast.',
                    'Top with egg and season with salt and pepper.',
                    'Serve immediately.',
                ]),
                'time'       => 10,
                'difficulty' => 'Easy',
                'category'   => 'Breakfast',
                'servings'   => 1,
                'is_vegetarian' => true,
                'is_gluten_free' => false,
                'is_lactose_free' => true,
                'ingredients' => [
                    ['name' => 'Bread',        'quantity' => '2 slices', 'is_main' => false, 'is_critical' => true],
                    ['name' => 'Avocado',      'quantity' => '1',        'is_main' => true,  'is_critical' => true],
                    ['name' => 'Eggs',         'quantity' => '1',        'is_main' => true,  'is_critical' => true],
                    ['name' => 'Lemon',        'quantity' => '1/2',      'is_main' => false, 'is_critical' => false],
                    ['name' => 'Salt',         'quantity' => 'to taste', 'is_main' => false, 'is_critical' => false],
                    ['name' => 'Black Pepper', 'quantity' => 'to taste', 'is_main' => false, 'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Salmon with Spinach',
                'image'       => 'https://images.pexels.com/photos/1516415/pexels-photo-1516415.jpeg?w=600&h=400&fit=crop',
                'description' => 'Pan-seared salmon on a bed of garlicky wilted spinach.',
                'instructions' => json_encode([
                    'Season salmon fillets with salt, pepper and lemon juice.',
                    'Heat oil in a pan over medium-high heat.',
                    'Sear salmon skin-side up for 4 minutes, then flip and cook 3 more minutes.',
                    'Remove salmon and keep warm.',
                    'In same pan, add garlic and spinach, cook until wilted (2 minutes).',
                    'Serve salmon on spinach with lemon wedges.',
                ]),
                'time'       => 20,
                'difficulty' => 'Medium',
                'category'   => 'Dinner',
                'servings'   => 2,
                'is_vegetarian' => false,
                'is_gluten_free' => true,
                'is_lactose_free' => true,
                'ingredients' => [
                    ['name' => 'Salmon',    'quantity' => '2 fillets', 'is_main' => true,  'is_critical' => true],
                    ['name' => 'Spinach',   'quantity' => '200g',      'is_main' => false, 'is_critical' => false],
                    ['name' => 'Garlic',    'quantity' => '3 cloves',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Lemon',     'quantity' => '1',         'is_main' => false, 'is_critical' => false],
                    ['name' => 'Olive Oil', 'quantity' => '2 tbsp',    'is_main' => false, 'is_critical' => false],
                    ['name' => 'Salt',      'quantity' => 'to taste',  'is_main' => false, 'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Mushroom Omelette',
                'image'       => 'https://images.pexels.com/photos/6605908/pexels-photo-6605908.jpeg?w=600&h=400&fit=crop',
                'description' => 'A hearty mushroom and cheese omelette for a filling breakfast.',
                'instructions' => json_encode([
                    'Sauté sliced mushrooms in butter until golden, season and set aside.',
                    'Whisk eggs with salt and pepper.',
                    'Melt butter in pan, add eggs, cook until mostly set.',
                    'Add mushrooms and cheese on one half.',
                    'Fold and slide onto plate.',
                    'Serve immediately.',
                ]),
                'time'       => 15,
                'difficulty' => 'Easy',
                'category'   => 'Breakfast',
                'servings'   => 1,
                'is_vegetarian' => true,
                'is_gluten_free' => true,
                'is_lactose_free' => false,
                'ingredients' => [
                    ['name' => 'Eggs',     'quantity' => '3',       'is_main' => true,  'is_critical' => true],
                    ['name' => 'Mushroom', 'quantity' => '100g',    'is_main' => false, 'is_critical' => false],
                    ['name' => 'Cheese',   'quantity' => '30g',     'is_main' => false, 'is_critical' => false],
                    ['name' => 'Butter',   'quantity' => '1 tbsp',  'is_main' => false, 'is_critical' => false],
                    ['name' => 'Salt',     'quantity' => 'to taste','is_main' => false, 'is_critical' => false],
                ],
            ],
            [
                'name'        => 'Vegetable Rice Bowl',
                'image'       => 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?w=600&h=400&fit=crop',
                'description' => 'A colourful and healthy rice bowl loaded with roasted vegetables.',
                'instructions' => json_encode([
                    'Cook rice according to package instructions.',
                    'Chop broccoli, carrot, zucchini and bell pepper.',
                    'Toss vegetables in olive oil, salt and pepper.',
                    'Roast at 200°C for 20 minutes until caramelised.',
                    'Serve vegetables over rice.',
                    'Drizzle with soy sauce.',
                ]),
                'time'       => 30,
                'difficulty' => 'Easy',
                'category'   => 'Lunch',
                'servings'   => 2,
                'is_vegetarian' => true,
                'is_gluten_free' => false,
                'is_lactose_free' => true,
                'ingredients' => [
                    ['name' => 'Rice',        'quantity' => '1.5 cups', 'is_main' => true,  'is_critical' => true],
                    ['name' => 'Broccoli',    'quantity' => '150g',     'is_main' => false, 'is_critical' => false],
                    ['name' => 'Carrot',      'quantity' => '2',        'is_main' => false, 'is_critical' => false],
                    ['name' => 'Zucchini',    'quantity' => '1',        'is_main' => false, 'is_critical' => false],
                    ['name' => 'Bell Pepper', 'quantity' => '1',        'is_main' => false, 'is_critical' => false],
                    ['name' => 'Olive Oil',   'quantity' => '2 tbsp',   'is_main' => false, 'is_critical' => false],
                    ['name' => 'Soy Sauce',   'quantity' => '1 tbsp',   'is_main' => false, 'is_critical' => false],
                    ['name' => 'Salt',        'quantity' => 'to taste', 'is_main' => false, 'is_critical' => false],
                ],
            ],
        ];

        foreach ($recipes as $recipeData) {
            $ingredientData = $recipeData['ingredients'];
            unset($recipeData['ingredients']);

            $recipe = Recipe::firstOrCreate(
                ['name' => $recipeData['name']],
                $recipeData
            );

            foreach ($ingredientData as $ing) {
                $ingredient = Ingredient::where('name', $ing['name'])->first();
                if ($ingredient) {
                    $recipe->recipeIngredients()->firstOrCreate(
                        ['ingredient_id' => $ingredient->id],
                        [
                            'quantity'      => $ing['quantity'],
                            'is_main'       => $ing['is_main'],
                            'is_critical'   => $ing['is_critical'],
                        ]
                    );
                }
            }
        }

        $fridgeIngredients = ['Eggs', 'Tomato', 'Chicken', 'Milk', 'Onion'];
        foreach ($fridgeIngredients as $name) {
            $ingredient = Ingredient::where('name', $name)->first();
            if ($ingredient) {
                $user->userIngredients()->updateOrCreate(
                    ['ingredient_id' => $ingredient->id],
                    ['expiry_date' => now()->addDays(rand(2, 6))->toDateString()]
                );
            }
        }

        foreach (['Nuts'] as $name) {
            $ingredient = Ingredient::firstOrCreate(
                ['name' => $name],
                ['emoji' => '🥜', 'category' => 'other']
            );
            $user->allergies()->firstOrCreate(['ingredient_id' => $ingredient->id]);
        }

        UserPreference::updateOrCreate(
            ['user_id' => $user->id],
            [
                'notifications_enabled' => true,
                'dark_mode' => false,
                'selected_language' => 'English',
                'selected_budget' => 'Medium',
                'diet_preferences' => ['Halal'],
            ]
        );

        $favoriteRecipeNames = [
            'Chicken Tomato Pasta',
            'Tomato Omelette',
            'Grilled Chicken Salad',
            'Egg Fried Rice',
        ];
        foreach ($favoriteRecipeNames as $name) {
            $recipe = Recipe::where('name', $name)->first();
            if ($recipe) {
                $user->favoriteRecipes()->firstOrCreate(['recipe_id' => $recipe->id]);
            }
        }

        $mealPlanDates = [
            ['dayOffset' => 0, 'mealType' => 'breakfast', 'recipe' => 'Tomato Omelette'],
            ['dayOffset' => 0, 'mealType' => 'lunch', 'recipe' => 'Grilled Chicken Salad'],
            ['dayOffset' => 1, 'mealType' => 'dinner', 'recipe' => 'Chicken Tomato Pasta'],
            ['dayOffset' => 2, 'mealType' => 'lunch', 'recipe' => 'Egg Fried Rice'],
            ['dayOffset' => 4, 'mealType' => 'breakfast', 'recipe' => 'Avocado Toast with Eggs'],
            ['dayOffset' => 6, 'mealType' => 'dinner', 'recipe' => 'Chicken Stir Fry'],
        ];

        $weekStart = Carbon::now()->startOfWeek();
        foreach ($mealPlanDates as $item) {
            $recipe = Recipe::where('name', $item['recipe'])->first();
            if ($recipe) {
                $user->mealPlans()->updateOrCreate(
                    [
                        'planned_date' => $weekStart->copy()->addDays($item['dayOffset'])->toDateString(),
                        'meal_type' => $item['mealType'],
                    ],
                    ['recipe_id' => $recipe->id]
                );
            }
        }

        foreach (['Chicken curry', 'Pasta recipes', 'Quick breakfast'] as $query) {
            $user->searchHistories()->create([
                'query' => $query,
                'searched_at' => now(),
            ]);
        }

        foreach (['Scrambled Eggs with Tomato', 'Chicken Tomato Pasta', 'Salmon with Spinach'] as $name) {
            $recipe = Recipe::where('name', $name)->first();
            if ($recipe) {
                $user->recipeHistories()->create([
                    'recipe_id' => $recipe->id,
                    'cooked_at' => now()->subDays(rand(0, 3)),
                ]);
            }
        }

        $shoppingList = ShoppingList::firstOrCreate(
            ['user_id' => $user->id, 'name' => 'Shopping List'],
            ['name' => 'Shopping List']
        );

        foreach ([
            ['ingredient_name' => 'Fresh Basil', 'quantity' => '1 bunch', 'category' => 'vegetables', 'is_checked' => false],
            ['ingredient_name' => 'Spinach', 'quantity' => '200g', 'category' => 'vegetables', 'is_checked' => false],
            ['ingredient_name' => 'Chicken Breast', 'quantity' => '500g', 'category' => 'meat', 'is_checked' => false],
            ['ingredient_name' => 'Greek Yogurt', 'quantity' => '500g', 'category' => 'dairy', 'is_checked' => false],
            ['ingredient_name' => 'Rice', 'quantity' => '1kg', 'category' => 'grains', 'is_checked' => false],
        ] as $item) {
            $shoppingList->items()->firstOrCreate(
                ['ingredient_name' => $item['ingredient_name']],
                $item
            );
        }
    }
}
