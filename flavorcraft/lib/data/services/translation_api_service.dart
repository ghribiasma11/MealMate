import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/session/session_store.dart';

class TranslationApiService {
  TranslationApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
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

  Future<Map<String, String>> translate({
    required String targetLanguage,
    required Map<String, String> texts,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/translations',
      data: {
        'source_language': 'en',
        'target_language': targetLanguage,
        'translations': texts,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>? ?? const {};
    final items =
        data['translations'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return items.map((key, value) => MapEntry(key, value.toString()));
  }
}
