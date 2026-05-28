import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/session/session_store.dart';

class AuthApiService {
  AuthApiService({Dio? dio})
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

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: {'email': email, 'password': password},
    );
    return response.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );
    return response.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<void> logout() async {
    await _dio.post('/logout');
  }
}
