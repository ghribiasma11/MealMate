import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const url = String.fromEnvironment('API_BASE_URL');
    if (url.isNotEmpty) {
      return url;
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }

    return 'http://localhost:8000/api/v1';
  }
}
