import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './meal_slot_card.dart';

class MealCalendarGrid extends StatefulWidget {
  final DateTime currentWeekStart;
  final Map<String, Map<String, Map<String, dynamic>>> weekMeals;
  final Function(int dayIndex, String mealType)? onAddRecipe;
  final Function(String recipeId, int dayIndex, String mealType)?
      onRecipeSelected;
  final Function(String recipeId, int fromDay, String fromMeal, int toDay,
      String toMeal)? onRecipeMoved;
  final Function(String recipeId, int dayIndex, String mealType)?
      onRecipeLongPress;

  const MealCalendarGrid({
    super.key,
    required this.currentWeekStart,
    required this.weekMeals,
    this.onAddRecipe,
    this.onRecipeSelected,
    this.onRecipeMoved,
    this.onRecipeLongPress,
  });

  @override
  State<MealCalendarGrid> createState() => _MealCalendarGridState();
}

class _MealCalendarGridState extends State<MealCalendarGrid> {
  String? _draggedRecipeId;
  int? _draggedFromDay;
  String? _draggedFromMeal;
  int? _dragTargetDay;
  String? _dragTargetMeal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x1A000000),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced header with date labels
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.accentOrange.withValues(alpha: 0.1)
                  : AppTheme.accentOrange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Space for meal type column header
                SizedBox(
                  width: 22.w,
                  child: Text(
                    'Week Overview',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentOrange,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Date headers with enhanced styling
                ...List.generate(7, (dayIndex) {
                  final currentDate =
                      widget.currentWeekStart.add(Duration(days: dayIndex));
                  final isToday = DateTime.now().day == currentDate.day &&
                      DateTime.now().month == currentDate.month;

                  return Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppTheme.accentOrange
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getDayName(dayIndex),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? AppTheme.pureWhite
                                  : AppTheme.mediumGray,
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${currentDate.day}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isToday
                                  ? AppTheme.pureWhite
                                  : (isDark
                                      ? AppTheme.pureWhite
                                      : AppTheme.textDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Enhanced meal rows with better spacing
          ...mealTypes.asMap().entries.map((entry) {
            final mealIndex = entry.key;
            final mealType = entry.value;

            return Container(
              margin: EdgeInsets.only(
                  bottom: mealIndex < mealTypes.length - 1 ? 2.h : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced meal type label section
                  SizedBox(
                    width: 22.w,
                    child: Container(
                      height: 14.h, // Fixed height for consistency
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getMealColor(mealType).withValues(alpha: 0.15),
                            _getMealColor(mealType).withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getMealColor(mealType).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Larger, more distinct meal icon
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: _getMealColor(mealType),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: _getMealColor(mealType)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CustomIconWidget(
                              iconName: _getMealIcon(mealType),
                              color: AppTheme.pureWhite,
                              size: 28, // Increased icon size
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          // Clear, legible meal label
                          Text(
                            mealType,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppTheme.pureWhite
                                  : AppTheme.textDark,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Day slots with consistent spacing
                  ...List.generate(7, (dayIndex) {
                    final dayKey = 'day_$dayIndex';
                    final mealData =
                        widget.weekMeals[dayKey]?[mealType.toLowerCase()];
                    final isEmpty = mealData == null;
                    final isDragTarget = _dragTargetDay == dayIndex &&
                        _dragTargetMeal == mealType;
                    final isDragging = _draggedRecipeId != null &&
                        _draggedFromDay == dayIndex &&
                        _draggedFromMeal == mealType;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                        child: DragTarget<Map<String, dynamic>>(
                          onWillAcceptWithDetails: (data) {
                            setState(() {
                              _dragTargetDay = dayIndex;
                              _dragTargetMeal = mealType;
                            });
                            return data != null;
                          },
                          onLeave: (data) {
                            setState(() {
                              _dragTargetDay = null;
                              _dragTargetMeal = null;
                            });
                          },
                          onAcceptWithDetails: (data) {
                            HapticFeedback.mediumImpact();
                            final fromDay = data.data['fromDay'] as int;
                            final fromMeal = data.data['fromMeal'] as String;
                            final recipeId = data.data['recipeId'] as String;

                            widget.onRecipeMoved?.call(recipeId, fromDay,
                                fromMeal, dayIndex, mealType);

                            setState(() {
                              _draggedRecipeId = null;
                              _draggedFromDay = null;
                              _draggedFromMeal = null;
                              _dragTargetDay = null;
                              _dragTargetMeal = null;
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            if (isEmpty) {
                              return MealSlotCard(
                                mealType: mealType,
                                dayIndex: dayIndex,
                                isEmpty: true,
                                isDragTarget: isDragTarget,
                                onTap: () => widget.onAddRecipe
                                    ?.call(dayIndex, mealType),
                              );
                            }

                            return Draggable<Map<String, dynamic>>(
                              data: {
                                'recipeId': mealData['id'],
                                'fromDay': dayIndex,
                                'fromMeal': mealType,
                              },
                              onDragStarted: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _draggedRecipeId = mealData['id'];
                                  _draggedFromDay = dayIndex;
                                  _draggedFromMeal = mealType;
                                });
                              },
                              onDragEnd: (details) {
                                setState(() {
                                  _draggedRecipeId = null;
                                  _draggedFromDay = null;
                                  _draggedFromMeal = null;
                                  _dragTargetDay = null;
                                  _dragTargetMeal = null;
                                });
                              },
                              feedback: Material(
                                color: Colors.transparent,
                                child: Transform.scale(
                                  scale: 1.05,
                                  child: Container(
                                    width: 25.w,
                                    height: 14.h,
                                    child: MealSlotCard(
                                      recipeId: mealData['id'],
                                      recipeName: mealData['name'],
                                      recipeImage: mealData['image'],
                                      prepTime: mealData['prepTime'],
                                      difficulty: mealData['difficulty'],
                                      mealType: mealType,
                                      dayIndex: dayIndex,
                                      isDragging: true,
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: MealSlotCard(
                                mealType: mealType,
                                dayIndex: dayIndex,
                                isEmpty: true,
                                isDragTarget: false,
                              ),
                              child: MealSlotCard(
                                recipeId: mealData['id'],
                                recipeName: mealData['name'],
                                recipeImage: mealData['image'],
                                prepTime: mealData['prepTime'],
                                difficulty: mealData['difficulty'],
                                mealType: mealType,
                                dayIndex: dayIndex,
                                isDragging: isDragging,
                                onTap: () => widget.onRecipeSelected
                                    ?.call(mealData['id'], dayIndex, mealType),
                                onLongPress: () => widget.onRecipeLongPress
                                    ?.call(mealData['id'], dayIndex, mealType),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getDayName(int dayIndex) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[dayIndex];
  }

  String _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'free_breakfast';
      case 'lunch':
        return 'lunch_dining';
      case 'dinner':
        return 'dinner_dining';
      default:
        return 'restaurant';
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return AppTheme.accentOrange;
      case 'lunch':
        return AppTheme.primaryGreen;
      case 'dinner':
        return Colors.deepPurple;
      default:
        return AppTheme.mediumGray;
    }
  }
}