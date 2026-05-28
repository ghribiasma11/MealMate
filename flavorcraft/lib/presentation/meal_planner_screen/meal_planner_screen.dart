import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/services/app_api_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/batch_cooking_tips_modal.dart';
import './widgets/cinema_meal_planner_widget.dart';
import './widgets/meal_calendar_grid.dart';
import './widgets/recipe_selection_modal.dart';
import './widgets/week_navigation_header.dart';
import './widgets/weekly_overview_card.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final AppApiService _appApiService = AppApiService();
  DateTime _currentWeekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  int _currentBottomNavIndex = 3;
  bool _isCinemaMode = true;
  bool _isLoading = true;

  Map<String, Map<String, Map<String, dynamic>>> _weekMeals = {
    for (var i = 0; i < 7; i++) 'day_$i': {},
  };
  List<Map<String, dynamic>> _batchCookingTips = [];

  @override
  void initState() {
    super.initState();
    _loadMealPlanner();
  }

  Future<void> _loadMealPlanner() async {
    final data = await _appApiService.getMealPlanner(
      _currentWeekStart.toIso8601String().split('T').first,
    );
    if (!mounted) return;

    final weekMeals = (data['weekMeals'] as Map<String, dynamic>? ?? const {})
        .map(
          (key, value) => MapEntry(
            key,
            (value as Map<String, dynamic>? ?? const {})
                .map(
                  (mealKey, mealValue) => MapEntry(
                    mealKey,
                    Map<String, dynamic>.from(mealValue as Map),
                  ),
                ),
          ),
        );

    setState(() {
      _weekMeals = weekMeals;
      _batchCookingTips =
          ((data['batchCookingTips'] as List<dynamic>? ?? const [])
                  .whereType<Map<String, dynamic>>()
                  .toList())
              .cast<Map<String, dynamic>>();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.pureWhite,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accentOrange),
              )
            : Column(
                children: [
                  WeekNavigationHeader(
                    currentWeekStart: _currentWeekStart,
                    onPreviousWeek: _navigateToPreviousWeek,
                    onNextWeek: _navigateToNextWeek,
                    onTodayPressed: _navigateToToday,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('View Mode', style: theme.textTheme.titleSmall),
                        Switch(
                          value: _isCinemaMode,
                          onChanged: (value) => setState(() => _isCinemaMode = value),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          WeeklyOverviewCard(
                            totalPrepTime: _calculateTotalPrepTime(),
                            ingredientOverlaps: _calculateIngredientOverlaps(),
                            batchCookingTips: _batchCookingTips
                                .map((tip) => tip['title'] as String? ?? '')
                                .where((title) => title.isNotEmpty)
                                .toList(),
                            onGenerateShoppingList: _generateShoppingList,
                            onViewBatchTips: _showBatchCookingTips,
                          ),
                          SizedBox(height: 2.h),
                          if (_isCinemaMode)
                            CinemaMealPlannerWidget(
                              currentWeekStart: _currentWeekStart,
                              weekMeals: _weekMeals,
                              onAddRecipe: _showRecipeSelectionModal,
                              onRecipeSelected: _navigateToRecipeDetail,
                              onRecipeLongPress: _showRecipeContextMenu,
                            )
                          else
                            MealCalendarGrid(
                              currentWeekStart: _currentWeekStart,
                              weekMeals: _weekMeals,
                              onAddRecipe: _showRecipeSelectionModal,
                              onRecipeSelected: _navigateToRecipeDetail,
                              onRecipeMoved: _moveRecipe,
                              onRecipeLongPress: _showRecipeContextMenu,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  void _navigateToPreviousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
      _isLoading = true;
    });
    _loadMealPlanner();
  }

  void _navigateToNextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
      _isLoading = true;
    });
    _loadMealPlanner();
  }

  void _navigateToToday() {
    final today = DateTime.now();
    setState(() {
      _currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
      _isLoading = true;
    });
    _loadMealPlanner();
  }

  int _calculateTotalPrepTime() {
    int totalTime = 0;
    for (final dayMeals in _weekMeals.values) {
      for (final meal in dayMeals.values) {
        totalTime += (meal['prepTime'] as int? ?? 0);
      }
    }
    return totalTime;
  }

  int _calculateIngredientOverlaps() {
    final ingredients = <String>{};
    for (final dayMeals in _weekMeals.values) {
      for (final meal in dayMeals.values) {
        ingredients.add((meal['name'] as String? ?? '').toLowerCase());
      }
    }
    return ingredients.length < _calculateMealCount() ? 1 : 0;
  }

  int _calculateMealCount() {
    int total = 0;
    for (final dayMeals in _weekMeals.values) {
      total += dayMeals.length;
    }
    return total;
  }

  void _generateShoppingList() {
    final recipeIds = <int>[];
    for (final dayMeals in _weekMeals.values) {
      for (final meal in dayMeals.values) {
        final id = int.tryParse((meal['id'] ?? '').toString());
        if (id != null) recipeIds.add(id);
      }
    }
    _appApiService.generateShoppingList(recipeIds: recipeIds);
    Navigator.pushNamed(context, AppRoutes.shoppingList);
  }

  void _showBatchCookingTips() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BatchCookingTipsModal(tips: _batchCookingTips),
    );
  }

  void _showRecipeSelectionModal(int dayIndex, String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecipeSelectionModal(
        mealType: mealType,
        dayIndex: dayIndex,
        onRecipeSelected: (recipe) => _addRecipeToSlot(recipe, dayIndex, mealType),
      ),
    );
  }

  Future<void> _addRecipeToSlot(
    Map<String, dynamic> recipe,
    int dayIndex,
    String mealType,
  ) async {
    final plannedDate =
        _currentWeekStart.add(Duration(days: dayIndex)).toIso8601String().split('T').first;
    final recipeId = (recipe['id'] as num?)?.toInt();
    if (recipeId == null) return;

    await _appApiService.saveMealPlanSlot(
      plannedDate: plannedDate,
      mealType: mealType,
      recipeId: recipeId,
    );
    await _loadMealPlanner();
  }

  void _navigateToRecipeDetail(String recipeId, int dayIndex, String mealType) {
    final id = int.tryParse(recipeId);
    if (id == null) return;
    Navigator.pushNamed(context, AppRoutes.recipeDetail, arguments: id);
  }

  Future<void> _moveRecipe(
    String recipeId,
    int fromDay,
    String fromMeal,
    int toDay,
    String toMeal,
  ) async {
    final fromDate =
        _currentWeekStart.add(Duration(days: fromDay)).toIso8601String().split('T').first;
    final toDate =
        _currentWeekStart.add(Duration(days: toDay)).toIso8601String().split('T').first;
    final id = int.tryParse(recipeId);
    if (id == null) return;

    await _appApiService.deleteMealPlanSlot(
      plannedDate: fromDate,
      mealType: fromMeal,
    );
    await _appApiService.saveMealPlanSlot(
      plannedDate: toDate,
      mealType: toMeal,
      recipeId: id,
    );
    await _loadMealPlanner();
  }

  void _showRecipeContextMenu(String recipeId, int dayIndex, String mealType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRecipeContextMenu(recipeId, dayIndex, mealType),
    );
  }

  Widget _buildRecipeContextMenu(String recipeId, int dayIndex, String mealType) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Recipe'),
              onTap: () {
                Navigator.pop(context);
                _navigateToRecipeDetail(recipeId, dayIndex, mealType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove Recipe'),
              onTap: () async {
                Navigator.pop(context);
                await _removeRecipe(dayIndex, mealType);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeRecipe(int dayIndex, String mealType) async {
    final plannedDate =
        _currentWeekStart.add(Duration(days: dayIndex)).toIso8601String().split('T').first;
    await _appApiService.deleteMealPlanSlot(
      plannedDate: plannedDate,
      mealType: mealType,
    );
    await _loadMealPlanner();
  }

  void _onBottomNavTap(int index) {
    if (index == _currentBottomNavIndex) return;
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.search);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.favorites);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.shoppingList);
        break;
    }
  }
}
