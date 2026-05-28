import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class IngredientReferenceWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients;
  final List<bool> checkedIngredients;
  final ValueChanged<int>? onIngredientToggle;

  const IngredientReferenceWidget({
    super.key,
    required this.ingredients,
    required this.checkedIngredients,
    this.onIngredientToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.black).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'restaurant',
                  color: AppTheme.accentOrange,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Ingredients Reference',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                Text(
                  '${checkedIngredients.where((checked) => checked).length}/${ingredients.length}',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            child: LinearProgressIndicator(
              value: checkedIngredients.where((checked) => checked).length /
                  ingredients.length,
              backgroundColor: AppTheme.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
              minHeight: 4,
            ),
          ),

          SizedBox(height: 2.h),

          // Ingredients list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: ingredients.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                final isChecked = index < checkedIngredients.length
                    ? checkedIngredients[index]
                    : false;
                final name = ingredient['name'] as String? ?? '';
                final amount = ingredient['amount'] as String? ?? '';
                final unit = ingredient['unit'] as String? ?? '';

                return GestureDetector(
                  onTap: () => onIngredientToggle?.call(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isChecked
                          ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                          : (isDark ? AppTheme.cardDark : AppTheme.softBackground),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isChecked
                            ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Checkbox
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: isChecked
                                ? AppTheme.primaryGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isChecked
                                  ? AppTheme.primaryGreen
                                  : AppTheme.mediumGray,
                              width: 2,
                            ),
                          ),
                          child: isChecked
                              ? CustomIconWidget(
                                  iconName: 'check',
                                  color: AppTheme.pureWhite,
                                  size: 16,
                                )
                              : null,
                        ),

                        SizedBox(width: 3.w),

                        // Ingredient details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isChecked
                                      ? AppTheme.mediumGray
                                      : (isDark
                                          ? AppTheme.pureWhite
                                          : AppTheme.textDark),
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              if (amount.isNotEmpty || unit.isNotEmpty) ...[
                                SizedBox(height: 0.5.h),
                                Text(
                                  '$amount $unit'.trim(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.mediumGray,
                                    decoration: isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Status icon
                        if (isChecked)
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.primaryGreen,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // Action buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Mark all as checked
                      for (int i = 0; i < ingredients.length; i++) {
                        if (i < checkedIngredients.length &&
                            !checkedIngredients[i]) {
                          onIngredientToggle?.call(i);
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppTheme.primaryGreen),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.primaryGreen,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Check All',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Clear all checks
                      for (int i = 0; i < ingredients.length; i++) {
                        if (i < checkedIngredients.length &&
                            checkedIngredients[i]) {
                          onIngredientToggle?.call(i);
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppTheme.mediumGray),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'clear',
                          color: AppTheme.mediumGray,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Clear All',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}