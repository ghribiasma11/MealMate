import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/session/session_store.dart';
import '../models/recipe.dart';

class RecipeApiService {
  RecipeApiService({Dio? dio})
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

  Future<List<Recipe>> fetchRecipes({
    String? difficulty,
    int? maxTime,
    bool vegetarian = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/recipes',
      queryParameters: {
        if (difficulty != null) 'difficulty': difficulty,
        if (maxTime != null) 'max_time': maxTime,
        if (vegetarian) 'vegetarian': true,
      },
    );

    final items = response.data?['data'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Recipe.fromJson)
        .toList();
  }

  Future<Recipe> fetchRecipe(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/recipes/$id');
    final data = response.data?['data'] as Map<String, dynamic>? ?? const {};
    return Recipe.fromJson(data);
  }
}
