import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_controller.dart';
import '../../data/services/app_api_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AppApiService _appApiService = AppApiService();
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> _ingredients = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _suggestions = <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final data = await _appApiService.getHome();
      if (!mounted) {
        return;
      }

      setState(() {
        _ingredients =
            ((data['ingredients'] as List<dynamic>? ?? const [])
                    .whereType<Map<String, dynamic>>()
                    .toList())
                .cast<Map<String, dynamic>>();
        _suggestions =
            ((data['suggestions'] as List<dynamic>? ?? const [])
                    .whereType<Map<String, dynamic>>()
                    .toList())
                .cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _addIngredient() async {
    final text = _ingredientController.text.trim();
    if (text.isEmpty) {
      return;
    }

    await _appApiService.addHomeIngredientByName(text);
    _ingredientController.clear();
    _focusNode.unfocus();
    await _loadHomeData();
  }

  Future<void> _removeIngredient(Map<String, dynamic> ingredient) async {
    final ingredientId = (ingredient['id'] as num?)?.toInt() ?? 0;
    if (ingredientId == 0) {
      return;
    }

    await _appApiService.removeHomeIngredient(ingredientId);
    await _loadHomeData();
  }

  Future<void> _addSuggestion(Map<String, dynamic> suggestion) async {
    final name = suggestion['name'] as String? ?? '';
    if (name.isEmpty) {
      return;
    }

    final exists = _ingredients.any(
      (item) =>
          (item['name'] as String? ?? '').toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      return;
    }

    await _appApiService.addHomeIngredientByName(name);
    await _loadHomeData();
  }

  void _findRecipes() {
    final app = AppController.instance;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            app.text('home.needIngredient'),
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: AppTheme.accentOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ingredientNames = _ingredients
        .map((item) => item['name'] as String? ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
    Navigator.pushNamed(context, AppRoutes.recipes, arguments: ingredientNames);
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
          currentIndex: 0,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
                            _buildHeader(app, colorScheme),
                            SizedBox(height: 3.h),
                            _buildInputSection(app, colorScheme),
                            SizedBox(height: 2.5.h),
                            _buildIngredientChips(app, colorScheme),
                            SizedBox(height: 2.5.h),
                            _buildSuggestionsSection(app, colorScheme),
                            SizedBox(height: 3.h),
                            _buildFindRecipesButton(app),
                            SizedBox(height: 3.h),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppController app, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, Color(0xFF2DB87A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.kitchen_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'FlavorCraft',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.person_outline_rounded, size: 22),
                color: colorScheme.onSurface,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.5.h),
        Text(
          app.text('home.title'),
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          app.text('home.subtitle'),
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(AppController app, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ingredientController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: app.text('home.searchHint'),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primaryGreen,
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _addIngredient(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _addIngredient,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientChips(AppController app, ColorScheme colorScheme) {
    if (_ingredients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.lightGray, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 36, color: colorScheme.onSurface),
            const SizedBox(height: 8),
            Text(
              app.text('home.emptyIngredients'),
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          app.text('home.yourIngredients'),
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _ingredients.map((ingredient) {
            final emoji = ingredient['emoji'] as String? ?? '';
            final name = ingredient['name'] as String? ?? '';
            return Chip(
              label: Text('$emoji $name'),
              backgroundColor: colorScheme.surface,
              side: BorderSide(color: colorScheme.outline),
              deleteIcon: const Icon(Icons.close_rounded, size: 16),
              onDeleted: () => _removeIngredient(ingredient),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(AppController app, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          app.text('home.quickAdd'),
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions.map((suggestion) {
            final name = suggestion['name'] as String? ?? '';
            final emoji = suggestion['emoji'] as String? ?? '';
            final isAdded = _ingredients.any(
              (item) =>
                  (item['name'] as String? ?? '').toLowerCase() ==
                  name.toLowerCase(),
            );
            return GestureDetector(
              onTap: isAdded ? null : () => _addSuggestion(suggestion),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isAdded
                      ? AppTheme.primaryGreen.withValues(alpha: 0.12)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAdded ? AppTheme.primaryGreen : colorScheme.outline,
                  ),
                ),
                child: Text(
                  '$emoji $name',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFindRecipesButton(AppController app) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _findRecipes,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accentOrange, Color(0xFFFF8A00)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                app.text('home.findRecipes'),
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
