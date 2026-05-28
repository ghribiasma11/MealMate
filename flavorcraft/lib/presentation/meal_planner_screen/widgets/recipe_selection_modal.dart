import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../data/services/app_api_service.dart';
import '../../../data/services/recipe_api_service.dart';

class RecipeSelectionModal extends StatefulWidget {
  final String mealType;
  final int dayIndex;
  final Function(Map<String, dynamic> recipe)? onRecipeSelected;

  const RecipeSelectionModal({
    super.key,
    required this.mealType,
    required this.dayIndex,
    this.onRecipeSelected,
  });

  @override
  State<RecipeSelectionModal> createState() => _RecipeSelectionModalState();
}

class _RecipeSelectionModalState extends State<RecipeSelectionModal>
    with TickerProviderStateMixin {
  final AppApiService _appApiService = AppApiService();
  final RecipeApiService _recipeApiService = RecipeApiService();
  late final TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _favoriteRecipes = [];
  List<Map<String, dynamic>> _recentRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final favorites = await _appApiService.getFavorites();
    final recipes = await _recipeApiService.fetchRecipes();
    if (!mounted) return;

    setState(() {
      _favoriteRecipes = favorites
          .map((item) => {
                'id': item['id'],
                'name': item['title'],
                'image': item['image'],
                'prepTime': int.tryParse(
                      (item['prepTime'] as String? ?? '0')
                          .replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ??
                    0,
                'difficulty': item['difficulty'],
                'category': item['category'],
                'ingredients': const <String>[],
              })
          .toList();
      _recentRecipes = recipes
          .take(8)
          .map((recipe) => {
                'id': recipe.id,
                'name': recipe.title,
                'image': recipe.image,
                'prepTime': recipe.time,
                'difficulty': recipe.difficulty,
                'category': recipe.category.toLowerCase(),
                'ingredients': recipe.ingredients
                    .map((ingredient) => ingredient.name)
                    .toList(),
              })
          .toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentOrange),
            )
          : Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.mediumGray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Recipe', style: theme.textTheme.headlineSmall),
                              Text('${widget.mealType} - Day ${widget.dayIndex + 1}'),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value.toLowerCase());
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search recipes...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : AppTheme.softBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.pureWhite,
                    unselectedLabelColor: AppTheme.mediumGray,
                    indicator: BoxDecoration(
                      color: AppTheme.accentOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tabs: const [Tab(text: 'Favorites'), Tab(text: 'Recent')],
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRecipeList(_getFilteredRecipes(_favoriteRecipes), isDark),
                      _buildRecipeList(_getFilteredRecipes(_recentRecipes), isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  List<Map<String, dynamic>> _getFilteredRecipes(
    List<Map<String, dynamic>> recipes,
  ) {
    if (_searchQuery.isEmpty) return recipes;
    return recipes.where((recipe) {
      final name = (recipe['name'] as String? ?? '').toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  Widget _buildRecipeList(List<Map<String, dynamic>> recipes, bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onRecipeSelected?.call(recipe);
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: recipe['image'],
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe['name']),
                      Text('${recipe['prepTime']} min'),
                      Text(recipe['difficulty']),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
