import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MealSlotCard extends StatelessWidget {
  final String? recipeId;
  final String? recipeName;
  final String? recipeImage;
  final int? prepTime;
  final String? difficulty;
  final String mealType;
  final int dayIndex;
  final bool isEmpty;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isDragTarget;
  final bool isDragging;

  const MealSlotCard({
    super.key,
    this.recipeId,
    this.recipeName,
    this.recipeImage,
    this.prepTime,
    this.difficulty,
    required this.mealType,
    required this.dayIndex,
    this.isEmpty = false,
    this.onTap,
    this.onLongPress,
    this.isDragTarget = false,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isEmpty) {
      return _buildEmptySlot(context, theme, isDark);
    }

    return _buildFilledSlot(context, theme, isDark);
  }

  Widget _buildEmptySlot(BuildContext context, ThemeData theme, bool isDark) {
    final mealColor = _getMealColor(mealType);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 14.h,
        decoration: BoxDecoration(
          color: isDragTarget
              ? mealColor.withValues(alpha: 0.15)
              : (isDark ? AppTheme.cardDark : AppTheme.cardWhite),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDragTarget
                ? mealColor
                : (isDark
                    ? AppTheme.mediumGray.withValues(alpha: 0.2)
                    : AppTheme.lightGray),
            width: isDragTarget ? 2 : 1.5,
          ),
          boxShadow: isDragTarget
              ? [
                  BoxShadow(
                    color: mealColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black26
                        : AppTheme.lightGray.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDragTarget
                    ? mealColor.withValues(alpha: 0.2)
                    : AppTheme.mediumGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDragTarget
                      ? mealColor.withValues(alpha: 0.4)
                      : AppTheme.mediumGray.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: isDragTarget ? 'file_download' : 'add',
                color: isDragTarget ? mealColor : AppTheme.mediumGray,
                size: 24,
              ),
            ),
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                isDragTarget ? 'Drop recipe here' : 'Add recipe',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDragTarget
                      ? mealColor
                      : (isDark
                          ? AppTheme.pureWhite.withValues(alpha: 0.7)
                          : AppTheme.mediumGray),
                  fontWeight: isDragTarget ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilledSlot(BuildContext context, ThemeData theme, bool isDark) {
    final mealColor = _getMealColor(mealType);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 14.h,
        decoration: BoxDecoration(
          color: isDragging
              ? (isDark ? AppTheme.cardDark : AppTheme.cardWhite)
                  .withValues(alpha: 0.8)
              : (isDark ? AppTheme.cardDark : AppTheme.cardWhite),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: mealColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
          border: isDragging
              ? Border.all(
                  color: mealColor,
                  width: 2.5,
                )
              : Border.all(
                  color: mealColor.withValues(alpha: 0.2),
                  width: 1,
                ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              if (recipeImage != null)
                Positioned.fill(
                  child: CustomImageWidget(
                    imageUrl: recipeImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 1.h,
                left: 1.h,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: mealColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: mealColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomIconWidget(
                    iconName: _getMealIcon(mealType),
                    color: AppTheme.pureWhite,
                    size: 16,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipeName ?? 'Unknown Recipe',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.pureWhite,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (prepTime != null || difficulty != null) ...[
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (prepTime != null) ...[
                                Container(
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentOrange
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'schedule',
                                    color: AppTheme.accentOrange,
                                    size: 14,
                                  ),
                                ),
                                SizedBox(width: 1.5.w),
                                Text(
                                  '${prepTime}min',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.pureWhite,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.sp,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                              if (prepTime != null && difficulty != null) ...[
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  width: 1,
                                  height: 3.h,
                                  color:
                                      AppTheme.pureWhite.withValues(alpha: 0.3),
                                ),
                              ],
                              if (difficulty != null) ...[
                                Container(
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: Colors.amber
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'star',
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                ),
                                SizedBox(width: 1.5.w),
                                Text(
                                  difficulty!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.pureWhite,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.sp,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isDragging)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: mealColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: mealColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: mealColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CustomIconWidget(
                          iconName: 'drag_indicator',
                          color: mealColor,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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