import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/services/app_api_service.dart';
import './widgets/empty_search_widget.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/recipe_search_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/search_filters_widget.dart';
import './widgets/search_suggestions_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final AppApiService _appApiService = AppApiService();
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  String _searchQuery = '';
  List<String> _recentSearches = [];
  List<String> _selectedFilters = [];
  List<String> _searchSuggestions = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _trendingRecipes = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
    _loadBootstrap();
  }

  Future<void> _loadBootstrap() async {
    final data = await _appApiService.getSearchBootstrap();
    if (!mounted) return;

    setState(() {
      _recentSearches = (data['recent_searches'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList();
      _searchSuggestions = (data['suggestions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList();
      _trendingRecipes = (data['trending_recipes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _showSuggestions = query.isNotEmpty && query.length >= 2;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (query.isEmpty) {
        setState(() {
          _searchResults.clear();
          _showSuggestions = false;
        });
        return;
      }
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final results = await _appApiService.searchRecipes(
      query: query,
      filters: _selectedFilters,
    );
    if (!mounted) return;

    setState(() {
      _searchResults = results;
      _isLoading = false;
      _showSuggestions = false;
    });
    await _loadBootstrap();
  }

  void _onVoicePressed() {
    setState(() => _isListening = !_isListening);

    if (_isListening) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _searchQuery = 'Chicken';
        });
        _onSearchChanged('Chicken');
      });
    }
  }

  void _onSuggestionTap(String suggestion) {
    setState(() => _searchQuery = suggestion);
    _performSearch(suggestion);
  }

  void _onRecentSearchTap(String search) {
    setState(() => _searchQuery = search);
    _performSearch(search);
  }

  void _onRemoveRecentSearch(String search) {
    setState(() => _recentSearches.remove(search));
  }

  void _onFilterToggle(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });

    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    }
  }

  void _onRecipeTap(Map<String, dynamic> recipe) {
    final recipeId = (recipe['id'] as num?)?.toInt();
    if (recipeId == null) return;
    Navigator.pushNamed(context, AppRoutes.recipeDetail, arguments: recipeId);
  }

  Future<void> _onFavoritePressed(Map<String, dynamic> recipe) async {
    final recipeId = (recipe['id'] as num?)?.toInt();
    if (recipeId == null) return;

    final isFavorite = recipe['isFavorite'] as bool? ?? false;
    if (isFavorite) {
      await _appApiService.removeFavorite(recipeId);
    } else {
      await _appApiService.addFavorite(recipeId);
    }

    setState(() {
      recipe['isFavorite'] = !isFavorite;
    });
  }

  void _onAddToMealPlan(Map<String, dynamic> recipe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${recipe['title']} ready for meal planner.')),
    );
  }

  void _onShareRecipe(Map<String, dynamic> recipe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${recipe['title']}...')),
    );
  }

  void _onClearFilters() {
    setState(() => _selectedFilters.clear());
    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.pureWhite,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildHeader(isDark),
              SearchBarWidget(
                initialSearchText: _searchQuery,
                onSearchChanged: _onSearchChanged,
                onVoicePressed: _onVoicePressed,
                onClearPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchResults.clear();
                    _showSuggestions = false;
                    _selectedFilters.clear();
                  });
                },
                isListening: _isListening,
              ),
              if (_searchQuery.isNotEmpty || _selectedFilters.isNotEmpty)
                SearchFiltersWidget(
                  selectedFilters: _selectedFilters,
                  onFilterToggle: _onFilterToggle,
                  onAdvancedFilters: () {},
                  activeFilterCount: _selectedFilters.length,
                ),
              Expanded(child: _buildContent(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.softBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Search Recipes',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isListening) {
      return Center(
        child: Text(
          'Listening...',
          style: GoogleFonts.inter(fontSize: 18.sp),
        ),
      );
    }

    if (_showSuggestions && _searchSuggestions.isNotEmpty) {
      return SearchSuggestionsWidget(
        suggestions: _searchSuggestions,
        onSuggestionTap: _onSuggestionTap,
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentOrange),
      );
    }

    if (_searchQuery.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            RecentSearchesWidget(
              recentSearches: _recentSearches,
              onSearchTap: _onRecentSearchTap,
              onRemoveSearch: _onRemoveRecentSearch,
            ),
            SizedBox(height: 2.h),
            EmptySearchWidget(
              trendingRecipes: _trendingRecipes,
              onTrendingTap: _onSuggestionTap,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return EmptySearchWidget(
        searchQuery: _searchQuery,
        trendingRecipes: _trendingRecipes,
        onTrendingTap: _onSuggestionTap,
        onClearFilters: _onClearFilters,
        hasActiveFilters: _selectedFilters.isNotEmpty,
      );
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          alignment: Alignment.centerLeft,
          child: Text('${_searchResults.length} recipes found'),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 2.h),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final recipe = _searchResults[index];
              return RecipeSearchCardWidget(
                recipe: recipe,
                searchQuery: _searchQuery,
                onTap: () => _onRecipeTap(recipe),
                onFavoritePressed: () => _onFavoritePressed(recipe),
                onAddToMealPlan: () => _onAddToMealPlan(recipe),
                onShare: () => _onShareRecipe(recipe),
              );
            },
          ),
        ),
      ],
    );
  }
}
