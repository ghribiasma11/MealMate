import 'package:flutter/material.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/recipes_screen/recipes_screen.dart';
import '../presentation/recipe_detail_screen/recipe_detail_screen.dart';
import '../presentation/shopping_list_screen/shopping_list_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/cooking_mode_screen/cooking_mode_screen.dart';
import '../presentation/search_screen/search_screen.dart';
import '../presentation/favorites_screen/favorites_screen.dart';
import '../presentation/meal_planner_screen/meal_planner_screen.dart';
import '../presentation/auth_screen/auth_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String auth = '/auth-screen';
  static const String home = '/home-screen';
  static const String recipes = '/recipes-screen';
  static const String search = '/search-screen';
  static const String favorites = '/favorites-screen';
  static const String mealPlanner = '/meal-planner-screen';
  static const String recipeDetail = '/recipe-detail-screen';
  static const String cookingMode = '/cooking-mode-screen';
  static const String shoppingList = '/shopping-list-screen';
  static const String profile = '/profile-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    auth: (context) => const AuthScreen(),
    home: (context) => const HomeScreen(),
    recipes: (context) => const RecipesScreen(),
    search: (context) => const SearchScreen(),
    favorites: (context) => const FavoritesScreen(),
    mealPlanner: (context) => const MealPlannerScreen(),
    recipeDetail: (context) => const RecipeDetailScreen(),
    cookingMode: (context) => const CookingModeScreen(),
    shoppingList: (context) => const ShoppingListScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
