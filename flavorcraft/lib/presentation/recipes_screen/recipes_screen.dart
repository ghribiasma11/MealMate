import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../data/models/recipe.dart';
import '../../data/services/recipe_api_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/main_scaffold.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final RecipeApiService _recipeApiService = RecipeApiService();
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _errorMessage;
  List<Recipe> _recipes = const <Recipe>[];

  final List<String> _filters = const [
    'All',
    'Quick',
    'Easy',
    'Vegetarian',
    'High Match',
  ];

  List<Recipe> get _filteredRecipes {
    if (_selectedFilter == 'All') return _recipes;
    if (_selectedFilter == 'Quick') {
      return _recipes.where((recipe) => recipe.time <= 15).toList();
    }
    if (_selectedFilter == 'Easy') {
      return _recipes.where((recipe) => recipe.difficulty == 'Easy').toList();
    }
    if (_selectedFilter == 'Vegetarian') {
      return _recipes.where((recipe) => recipe.isVegetarian).toList();
    }
    if (_selectedFilter == 'High Match') {
      return _recipes.where((recipe) => (recipe.matchScore ?? 0) >= 70).toList();
    }
    return _recipes;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipes = await _recipeApiService.fetchRecipes();
      if (!mounted) return;

      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
      _animController.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger les recettes depuis Laravel. Verifie que l API tourne ou pas.';
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _matchColor(int score) {
    if (score >= 80) return AppTheme.primaryGreen;
    if (score >= 60) return AppTheme.accentOrange;
    return AppTheme.mediumGray;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final ingredients = args is List ? args : const [];

    return MainScaffold(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: AppTheme.softBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ingredients.length),
              _buildFilters(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int ingredientCount) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recipes',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  ingredientCount > 0
                      ? 'Based on $ingredientCount ingredients'
                      : 'Loaded from your Laravel API',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_filteredRecipes.length} found',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.softBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : AppTheme.lightGray,
                  ),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.mediumGray,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.mediumGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRecipes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredRecipes.isEmpty) {
      return Center(
        child: Text(
          'No recipes found in database.',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppTheme.mediumGray,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryGreen,
      onRefresh: _loadRecipes,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        itemCount: _filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _filteredRecipes[index];
          return AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final delay = index * 0.08;
              final animValue = Curves.easeOut.transform(
                (_animController.value - delay).clamp(0.0, 1.0),
              );
              return Transform.translate(
                offset: Offset(0, 20 * (1 - animValue)),
                child: Opacity(opacity: animValue, child: child),
              );
            },
            child: _buildRecipeCard(recipe),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final matchScore = recipe.matchScore ?? 0;
    final matchColor = _matchColor(matchScore);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: recipe,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: recipe.image,
                    height: 20.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 20.h,
                      color: AppTheme.lightGray,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 20.h,
                      color: AppTheme.lightGray,
                      child: const Icon(
                        Icons.restaurant,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ),
                ),
                if (matchScore > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: matchColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$matchScore%',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recipe.category,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.timer_outlined,
                        '${recipe.time} min',
                        AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.bar_chart_rounded,
                        recipe.difficulty,
                        AppTheme.accentOrange,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.softBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${recipe.ingredients.length} ingredients',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.mediumGray,
          ),
        ),
      ],
    );
  }
}
