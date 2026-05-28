import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/app_api_service.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/translation_api_service.dart';
import 'localization/app_localizations.dart';
import 'session/session_store.dart';

class AppController extends ChangeNotifier {
  AppController._();

  static final AppController instance = AppController._();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _darkModeKey = 'dark_mode';
  static const _languageKey = 'selected_language';
  static const _translationCachePrefix = 'translations_';

  final AuthApiService _authApiService = AuthApiService();
  final AppApiService _appApiService = AppApiService();
  final TranslationApiService _translationApiService = TranslationApiService();

  bool _isReady = false;
  bool _isAuthenticating = false;
  ThemeMode _themeMode = ThemeMode.light;
  String _selectedLanguage = 'English';
  Map<String, String> _translations = Map<String, String>.from(
    AppLocalizations.defaults,
  );

  bool get isReady => _isReady;
  bool get isAuthenticating => _isAuthenticating;
  bool get isAuthenticated =>
      SessionStore.authToken != null && SessionStore.authToken!.isNotEmpty;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get selectedLanguage => _selectedLanguage;
  Map<String, dynamic>? get currentUser => SessionStore.user;

  String text(String key) => _translations[key] ?? AppLocalizations.defaults[key] ?? key;

  Future<void> initialize() async {
    if (_isReady) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    final language = prefs.getString(_languageKey) ?? 'English';

    SessionStore.authToken = token;
    SessionStore.user = userJson == null
        ? null
        : jsonDecode(userJson) as Map<String, dynamic>;

    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _selectedLanguage = language;
    _translations = await _loadTranslations(prefs, language);
    _isReady = true;
    notifyListeners();

    if (isAuthenticated) {
      await hydrateRemotePreferences();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isAuthenticating = true;
    notifyListeners();

    try {
      final data = await _authApiService.login(email: email, password: password);
      await _persistSession(data);
      await hydrateRemotePreferences();
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isAuthenticating = true;
    notifyListeners();

    try {
      final data = await _authApiService.register(
        name: name,
        email: email,
        password: password,
      );
      await _persistSession(data);
      await hydrateRemotePreferences();
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      if (isAuthenticated) {
        await _authApiService.logout();
      }
    } catch (_) {
      // Local cleanup still happens if the remote logout fails.
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    SessionStore.authToken = null;
    SessionStore.user = null;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    _translations = await _loadTranslations(prefs, language, forceRefresh: true);
    notifyListeners();
  }

  Future<void> hydrateRemotePreferences() async {
    try {
      final profile = await _appApiService.getProfile();
      final settings = profile['settings'] as Map<String, dynamic>? ?? const {};
      final remoteDarkMode = settings['dark_mode'] as bool? ?? isDarkMode;
      final remoteLanguage =
          settings['selected_language'] as String? ?? _selectedLanguage;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, remoteDarkMode);
      await prefs.setString(_languageKey, remoteLanguage);
      _themeMode = remoteDarkMode ? ThemeMode.dark : ThemeMode.light;
      _selectedLanguage = remoteLanguage;
      _translations = await _loadTranslations(prefs, remoteLanguage);
      notifyListeners();
    } catch (_) {
      // Keep local preferences when the profile call is unavailable.
    }
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    final token = data['token']?.toString() ?? '';
    final user = data['user'] as Map<String, dynamic>? ?? const {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
    SessionStore.authToken = token;
    SessionStore.user = user;
  }

  Future<Map<String, String>> _loadTranslations(
    SharedPreferences prefs,
    String language, {
    bool forceRefresh = false,
  }) async {
    final languageCode = AppLocalizations.languageCodes[language] ?? 'en';
    if (languageCode == 'en') {
      return Map<String, String>.from(AppLocalizations.defaults);
    }

    final cacheKey = '$_translationCachePrefix$languageCode';
    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        final decoded = jsonDecode(cached) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
    }

    try {
      final translated = await _translationApiService.translate(
        targetLanguage: languageCode,
        texts: AppLocalizations.defaults,
      );
      await prefs.setString(cacheKey, jsonEncode(translated));
      return translated;
    } on DioException {
      return Map<String, String>.from(AppLocalizations.defaults);
    }
  }
}
