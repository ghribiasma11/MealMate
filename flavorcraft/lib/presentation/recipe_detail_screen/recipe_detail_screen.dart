import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../data/models/recipe.dart';
import '../../data/services/recipe_api_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  final RecipeApiService _recipeApiService = RecipeApiService();
  bool _isFavorite = false;
  int _selectedTab = 0;
  bool _isLoading = true;
  String? _errorMessage;
  Recipe? _recipe;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveRecipe());
  }

  Future<void> _resolveRecipe() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    try {
      Recipe recipe;
      if (args is int) {
        recipe = await _recipeApiService.fetchRecipe(args);
      } else {
        recipe = Recipe.fromDynamic(args);
        recipe = await _recipeApiService.fetchRecipe(recipe.id);
      }

      if (!mounted) return;
      setState(() {
        _recipe = recipe;
        _isLoading = false;
      });
      _animController.forward();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger le detail de la recette depuis Laravel.';
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _addMissingToShoppingList(List<String> missingIngredients) {
    Navigator.pushNamed(
      context,
      AppRoutes.shoppingList,
      arguments: missingIngredients,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Missing ingredients added to shopping list.',
          style: GoogleFonts.dmSans(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.softBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    if (_errorMessage != null || _recipe == null) {
      return Scaffold(
        backgroundColor: AppTheme.softBackground,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Text(
              _errorMessage ?? 'Recipe not found.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.mediumGray,
                height: 1.5,
              ),
            ),
          ),
        ),
      );
    }

    final recipe = _recipe!;
    final ingredientsHave = recipe.availableIngredients;
    final ingredientsMissing = recipe.ingredientsMissing;
    final steps = recipe.instructions;

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildHeroSection(recipe),
                SliverToBoxAdapter(child: _buildRecipeInfo(recipe)),
                SliverToBoxAdapter(child: _buildTabSelector()),
                SliverToBoxAdapter(
                  child: _selectedTab == 0
                      ? _buildIngredientsTab(recipe, ingredientsHave, ingredientsMissing)
                      : _buildStepsTab(steps),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 18.h)),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomActions(recipe, ingredientsMissing),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(Recipe recipe) {
    return SliverAppBar(
      expandedHeight: 30.h,
      pinned: true,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppTheme.textDark,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _isFavorite = !_isFavorite),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: _isFavorite ? Colors.red : AppTheme.textDark,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: recipe.image,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppTheme.lightGray),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.lightGray,
                child: const Icon(
                  Icons.restaurant,
                  color: AppTheme.mediumGray,
                  size: 48,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            if (recipe.matchScore != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${recipe.matchScore}% match',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInfo(Recipe recipe) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          if (recipe.description.isNotEmpty)
            Text(
              recipe.description,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.mediumGray,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Time', '${recipe.time} min'),
              const SizedBox(width: 12),
              _buildStatCard('Level', recipe.difficulty),
              const SizedBox(width: 12),
              _buildStatCard('Servings', '${recipe.servings}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.softBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          _buildTab(0, 'Ingredients'),
          const SizedBox(width: 8),
          _buildTab(1, 'Steps'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.softBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.mediumGray,
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsTab(
    Recipe recipe,
    List<String> have,
    List<String> missing,
  ) {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Recipe ingredients (${recipe.ingredients.length})',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),
          ...recipe.ingredients.map(
            (ingredient) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    ingredient.emoji.isNotEmpty ? ingredient.emoji : '•',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Text(
                    ingredient.quantity,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (have.isNotEmpty || missing.isNotEmpty) const Divider(height: 24),
          if (have.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Available now (${have.length})',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ...have.map((ingredient) => _buildIngredientRow(ingredient, true)),
          if (missing.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Missing (${missing.length})',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentOrange,
                ),
              ),
            ),
          ...missing.map((ingredient) => _buildIngredientRow(ingredient, false)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(String ingredient, bool have) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            have ? Icons.check_rounded : Icons.close_rounded,
            size: 18,
            color: have ? AppTheme.primaryGreen : AppTheme.accentOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab(List<String> steps) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.textDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomActions(Recipe recipe, List<String> missing) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 12, 4.w, 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.cookingMode,
                arguments: recipe,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Start Cooking',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _addMissingToShoppingList(missing),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                missing.isEmpty ? 'All Set' : 'Add Missing (${missing.length})',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
