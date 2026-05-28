import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class QuickActionsSheet extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onAddToFavorites;
  final VoidCallback onAddToMealPlan;
  final VoidCallback onShareRecipe;

  const QuickActionsSheet({
    super.key,
    required this.recipe,
    required this.onAddToFavorites,
    required this.onAddToMealPlan,
    required this.onShareRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.pureWhite,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.mediumGray.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          // Recipe Preview
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: recipe["image"] as String,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe["title"] as String,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? AppTheme.pureWhite : AppTheme.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'access_time',
                            color: AppTheme.mediumGray,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            "${recipe["prepTime"]} min",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          CustomIconWidget(
                            iconName: 'star',
                            color: AppTheme.accentOrange,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            "${recipe["rating"]}",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mediumGray,
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
          SizedBox(height: 4.h),
          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                _buildActionButton(
                  context,
                  icon: (recipe["isFavorite"] as bool)
                      ? 'favorite'
                      : 'favorite_border',
                  label: (recipe["isFavorite"] as bool)
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  color: AppTheme.errorRed,
                  onTap: onAddToFavorites,
                  isDark: isDark,
                ),
                SizedBox(height: 2.h),
                _buildActionButton(
                  context,
                  icon: 'calendar_today',
                  label: 'Add to Meal Plan',
                  color: AppTheme.successGreen,
                  onTap: onAddToMealPlan,
                  isDark: isDark,
                ),
                SizedBox(height: 2.h),
                _buildActionButton(
                  context,
                  icon: 'share',
                  label: 'Share Recipe',
                  color: AppTheme.primaryGreen,
                  onTap: onShareRecipe,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 4.w),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}