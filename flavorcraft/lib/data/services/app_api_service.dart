import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/session/session_store.dart';

class AppApiService {
  AppApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: const {'Accept': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SessionStore.authToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  Future<Map<String, dynamic>> getHome() async {
    final response = await _dio.get<Map<String, dynamic>>('/app/home');
    return response.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<void> addHomeIngredientByName(String name) async {
    await _dio.post('/app/home/ingredients/by-name', data: {'name': name});
  }

  Future<void> removeHomeIngredient(int ingredientId) async {
    await _dio.delete('/app/home/ingredients/$ingredientId');
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await _dio.get<Map<String, dynamic>>('/app/favorites');
    final items = response.data?['data'] as List<dynamic>? ?? const [];
    return items.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> addFavorite(int recipeId) async {
    await _dio.post('/app/favorites/$recipeId');
  }

  Future<void> removeFavorite(int recipeId) async {
    await _dio.delete('/app/favorites/$recipeId');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/app/profile');
    return response.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<void> updateProfileSettings(Map<String, dynamic> settings) async {
    await _dio.patch('/app/profile/settings', data: settings);
  }

  Future<void> addAllergy(int ingredientId) async {
    await _dio.post(
      '/app/profile/allergies',
      data: {'ingredient_id': ingredientId},
    );
  }

  Future<void> removeAllergy(int ingredientId) async {
    await _dio.delete('/app/profile/allergies/$ingredientId');
  }

  Future<Map<String, dynamic>> getSearchBootstrap() async {
    final response = await _dio.get<Map<String, dynamic>>('/app/search/bootstrap');
    return response.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<List<Map<String, dynamic>>> searchRecipes({
    String query = '',
    List<String> filters = const [],
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/app/search',
      queryParameters: {
        if (query.isNotEmpty) 'q': query,
        if (filters.isNotEmpty) 'filters': filters,
      },
    );
    final items = response.data?['data'] as List<dynamic>? ?? const [];
    return items.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getMealPlanner(String weekStart) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/app/meal-planner',
      queryParameters: {'week_start': weekStart},
    );
    return response.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<void> saveMealPlanSlot({
    required String plannedDate,
    required String mealType,
    required int recipeId,
  }) async {
    await _dio.post(
      '/app/meal-planner/slots',
      data: {
        'planned_date': plannedDate,
        'meal_type': mealType,
        'recipe_id': recipeId,
      },
    );
  }

  Future<void> deleteMealPlanSlot({
    required String plannedDate,
    required String mealType,
  }) async {
    await _dio.delete(
      '/app/meal-planner/slots',
      data: {
        'planned_date': plannedDate,
        'meal_type': mealType,
      },
    );
  }

  Future<Map<String, dynamic>> getShoppingList() async {
    final response = await _dio.get<Map<String, dynamic>>('/app/shopping-list');
    return response.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<void> generateShoppingList({
    List<int> recipeIds = const [],
    List<String> missingIngredients = const [],
  }) async {
    await _dio.post(
      '/app/shopping-list/generate',
      data: {
        'recipe_ids': recipeIds,
        'missing_ingredients': missingIngredients,
      },
    );
  }

  Future<void> addShoppingItem({
    required String ingredientName,
    String? quantity,
  }) async {
    await _dio.post(
      '/app/shopping-list/items',
      data: {
        'ingredient_name': ingredientName,
        'quantity': quantity,
      },
    );
  }

  Future<void> updateShoppingItem({
    required int itemId,
    required bool isChecked,
  }) async {
    await _dio.patch(
      '/app/shopping-list/items/$itemId',
      data: {'is_checked': isChecked},
    );
  }

  Future<void> deleteShoppingItem(int itemId) async {
    await _dio.delete('/app/shopping-list/items/$itemId');
  }
}
