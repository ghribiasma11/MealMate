import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_controller.dart';
import '../../data/services/app_api_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final AppApiService _appApiService = AppApiService();
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  List<Map<String, dynamic>> _allergies = [];
  List<Map<String, dynamic>> _dietPreferences = [];
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic> _user = {};
  bool _darkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _appApiService.getProfile();
    if (!mounted) {
      return;
    }

    final settings = data['settings'] as Map<String, dynamic>? ?? const {};
    setState(() {
      _allergies = ((data['allergies'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList())
          .cast<Map<String, dynamic>>();
      _dietPreferences =
          ((data['diet_preferences'] as List<dynamic>? ?? const [])
                  .whereType<Map<String, dynamic>>()
                  .toList())
              .cast<Map<String, dynamic>>();
      _history = ((data['history'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList())
          .cast<Map<String, dynamic>>();
      _user = data['user'] as Map<String, dynamic>? ?? const {};
      _darkMode = settings['dark_mode'] as bool? ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _appApiService.updateProfileSettings({
      'dark_mode': _darkMode,
      'diet_preferences': _dietPreferences
          .where((item) => item['active'] == true)
          .map((item) => item['name'])
          .toList(),
    });
  }

  Future<void> _logout() async {
    await AppController.instance.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.auth, (_) => false);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        final app = AppController.instance;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return MainScaffold(
          currentIndex: 3,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: FadeTransition(
              opacity: _fadeAnim,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    )
                  : SafeArea(
                      child: Column(
                        children: [
                          _buildHeader(app, colorScheme),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProfileCard(app),
                                  SizedBox(height: 2.h),
                                  _buildSectionTitle(
                                    app.text('profile.allergies'),
                                    colorScheme,
                                  ),
                                  SizedBox(height: 1.h),
                                  _buildAllergyFilters(colorScheme),
                                  SizedBox(height: 2.h),
                                  _buildSectionTitle(
                                    app.text('profile.diet'),
                                    colorScheme,
                                  ),
                                  SizedBox(height: 1.h),
                                  _buildDietPreferences(colorScheme),
                                  SizedBox(height: 2.h),
                                  _buildSectionTitle(
                                    app.text('profile.settings'),
                                    colorScheme,
                                  ),
                                  SizedBox(height: 1.h),
                                  _buildSettingsCard(app, colorScheme),
                                  SizedBox(height: 2.h),
                                  _buildSectionTitle(
                                    app.text('profile.history'),
                                    colorScheme,
                                  ),
                                  SizedBox(height: 1.h),
                                  _buildRecipeHistory(colorScheme),
                                  SizedBox(height: 2.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: _logout,
                                      child: Text(app.text('profile.logout')),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppController app, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          Text(
            app.text('profile.title'),
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AppController app) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF2DB87A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user['name'] as String? ?? 'User',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _user['email'] as String? ?? '',
                  style: GoogleFonts.dmSans(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatBadge(
                      '${_user['recipe_count'] ?? 0}',
                      app.text('profile.recipeCount'),
                    ),
                    const SizedBox(width: 8),
                    _buildStatBadge(
                      '${_user['favorite_count'] ?? 0}',
                      app.text('profile.favoriteCount'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$value $label',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildAllergyFilters(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allergies.map((allergy) {
        final isActive = allergy['active'] as bool? ?? false;
        return GestureDetector(
          onTap: () async {
            final id = (allergy['id'] as num?)?.toInt();
            if (id == null) {
              return;
            }
            if (isActive) {
              await _appApiService.removeAllergy(id);
            } else {
              await _appApiService.addAllergy(id);
            }
            await _loadProfile();
          },
          child: Chip(
            label: Text('${allergy['emoji'] ?? ''} ${allergy['name']}'),
            backgroundColor: isActive
                ? AppTheme.errorRed.withValues(alpha: 0.1)
                : colorScheme.surface,
            side: BorderSide(
              color: isActive ? AppTheme.errorRed : colorScheme.outline,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDietPreferences(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _dietPreferences.asMap().entries.map((entry) {
        final index = entry.key;
        final pref = entry.value;
        final isActive = pref['active'] as bool? ?? false;
        return GestureDetector(
          onTap: () async {
            setState(() => _dietPreferences[index]['active'] = !isActive);
            await _saveSettings();
          },
          child: Chip(
            label: Text(pref['name'] as String? ?? ''),
            backgroundColor: isActive
                ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                : colorScheme.surface,
            side: BorderSide(
              color: isActive ? AppTheme.primaryGreen : colorScheme.outline,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsCard(AppController app, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            app.text('profile.darkMode'),
            Switch(
              value: _darkMode,
              onChanged: (value) async {
                setState(() => _darkMode = value);
                await AppController.instance.setDarkMode(value);
                await _saveSettings();
              },
            ),
            colorScheme,
          ),
          _buildDivider(colorScheme),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    String title,
    Widget trailing,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Divider(height: 1, color: colorScheme.outlineVariant);
  }

  Widget _buildRecipeHistory(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _history.map((item) {
          return ListTile(
            title: Text(
              item['title'] as String? ?? '',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            trailing: Text(
              item['date'] as String? ?? '',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          );
        }).toList(),
      ),
    );
  }
}
