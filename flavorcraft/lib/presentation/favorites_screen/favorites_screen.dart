import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/services/app_api_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/recipe_card_widget.dart';
import './widgets/search_bar_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  final GlobalKey<SearchBarWidgetState> _searchBarKey =
      GlobalKey<SearchBarWidgetState>();
  final ScrollController _scrollController = ScrollController();
  final AppApiService _appApiService = AppApiService();

  bool _isGridView = true;
  bool _isSelectionMode = false;
  bool _isLoading = true;
  String _searchQuery = '';
  Map<String, dynamic> _filters = {
    'categories': <String>[],
    'minPrepTime': 0.0,
    'maxPrepTime': 120.0,
    'difficulties': <String>[],
  };

  Set<int> _selectedRecipes = <int>{};
  List<Map<String, dynamic>> _favoriteRecipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];

  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
    _loadFavorites();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _appApiService.getFavorites();
    if (!mounted) return;

    setState(() {
      _favoriteRecipes = favorites;
      _filteredRecipes = List.from(favorites);
      _isLoading = false;
    });
    _applyFilters();
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 &&
          !_fabAnimationController.isCompleted) {
        _fabAnimationController.forward();
      } else if (_scrollController.offset <= 100 &&
          _fabAnimationController.isCompleted) {
        _fabAnimationController.reverse();
      }
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRecipes = _favoriteRecipes.where((recipe) {
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final title = (recipe["title"] as String? ?? '').toLowerCase();
          final description =
              (recipe["description"] as String? ?? '').toLowerCase();
          if (!title.contains(query) && !description.contains(query)) {
            return false;
          }
        }

        final categories = _filters['categories'] as List<String>;
        if (categories.isNotEmpty && !categories.contains('All')) {
          if (!categories.contains(recipe["category"] as String? ?? '')) {
            return false;
          }
        }

        final prepTimeStr = recipe["prepTime"] as String? ?? '0';
        final prepTime =
            int.tryParse(prepTimeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final minPrepTime = _filters['minPrepTime'] as double;
        final maxPrepTime = _filters['maxPrepTime'] as double;
        if (prepTime < minPrepTime || prepTime > maxPrepTime) {
          return false;
        }

        final difficulties = _filters['difficulties'] as List<String>;
        if (difficulties.isNotEmpty &&
            !difficulties.contains(recipe["difficulty"] as String? ?? '')) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  Future<void> _removeFavorite(int recipeId) async {
    await _appApiService.removeFavorite(recipeId);
    await _loadFavorites();
  }

  void _toggleViewMode() {
    HapticFeedback.lightImpact();
    setState(() => _isGridView = !_isGridView);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _filters,
        onFiltersChanged: (newFilters) {
          setState(() => _filters = newFilters);
          _applyFilters();
        },
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedRecipes.clear();
      }
    });
  }

  void _toggleRecipeSelection(int recipeId) {
    setState(() {
      if (_selectedRecipes.contains(recipeId)) {
        _selectedRecipes.remove(recipeId);
      } else {
        _selectedRecipes.add(recipeId);
      }
    });
  }

  Future<void> _deleteSelectedRecipes() async {
    final ids = _selectedRecipes.toList();
    for (final id in ids) {
      await _appApiService.removeFavorite(id);
    }
    setState(() {
      _selectedRecipes.clear();
      _isSelectionMode = false;
    });
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.pureWhite,
      appBar: _buildAppBar(isDark),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              color: AppTheme.primaryGreen,
              child: Column(
                children: [
                  SearchBarWidget(
                    key: _searchBarKey,
                    onSearchChanged: (query) {
                      setState(() => _searchQuery = query);
                      _applyFilters();
                    },
                  ),
                  Expanded(
                    child: _filteredRecipes.isEmpty
                        ? _favoriteRecipes.isEmpty
                            ? EmptyStateWidget(
                                onExploreRecipes: () {
                                  Navigator.pushNamed(context, AppRoutes.home);
                                },
                              )
                            : _buildNoResultsState(isDark)
                        : _buildRecipesList(isDark),
                  ),
                ],
              ),
            ),
      floatingActionButton: _isSelectionMode
          ? _buildSelectionFAB()
          : _buildScrollToTopFAB(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.search);
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.mealPlanner);
              break;
            case 4:
              Navigator.pushReplacementNamed(context, AppRoutes.shoppingList);
              break;
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.pureWhite,
      title: Text(
        _isSelectionMode
            ? '${_selectedRecipes.length} Selected'
            : 'My Favorites',
      ),
      leading: _isSelectionMode
          ? IconButton(
              onPressed: _toggleSelectionMode,
              icon: const Icon(Icons.close),
            )
          : null,
      actions: [
        if (!_isSelectionMode) ...[
          IconButton(
            onPressed: () => _searchBarKey.currentState?.showSearch(),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: _toggleViewMode,
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          ),
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.tune),
          ),
        ] else if (_selectedRecipes.isNotEmpty)
          IconButton(
            onPressed: _deleteSelectedRecipes,
            icon: const Icon(Icons.delete, color: AppTheme.errorRed),
          ),
      ],
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Text(
        'No recipes found',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildRecipesList(bool isDark) {
    return _isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: _filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _filteredRecipes[index];
        final recipeId = (recipe["id"] as num).toInt();
        return RecipeCardWidget(
          recipe: recipe,
          isGridView: true,
          isSelected: _selectedRecipes.contains(recipeId),
          isSelectionMode: _isSelectionMode,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.recipeDetail,
            arguments: recipeId,
          ),
          onFavoriteToggle: () => _removeFavorite(recipeId),
          onSelectionToggle: () {
            if (!_isSelectionMode) _toggleSelectionMode();
            _toggleRecipeSelection(recipeId);
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      itemCount: _filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _filteredRecipes[index];
        final recipeId = (recipe["id"] as num).toInt();
        return RecipeCardWidget(
          recipe: recipe,
          isGridView: false,
          isSelected: _selectedRecipes.contains(recipeId),
          isSelectionMode: _isSelectionMode,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.recipeDetail,
            arguments: recipeId,
          ),
          onFavoriteToggle: () => _removeFavorite(recipeId),
          onSelectionToggle: () {
            if (!_isSelectionMode) _toggleSelectionMode();
            _toggleRecipeSelection(recipeId);
          },
        );
      },
    );
  }

  Widget _buildSelectionFAB() {
    return _selectedRecipes.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: _deleteSelectedRecipes,
            backgroundColor: AppTheme.errorRed,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.delete),
            label: Text('Delete (${_selectedRecipes.length})'),
          )
        : const SizedBox.shrink();
  }

  Widget _buildScrollToTopFAB() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: AppTheme.accentOrange,
        child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
      ),
    );
  }
}
