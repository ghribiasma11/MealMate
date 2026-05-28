import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BatchCookingTipsModal extends StatelessWidget {
  final List<Map<String, dynamic>> tips;

  const BatchCookingTipsModal({
    super.key,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.mediumGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomIconWidget(
                            iconName: 'lightbulb',
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Batch Cooking Tips',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppTheme.pureWhite
                                    : AppTheme.textDark,
                              ),
                            ),
                            Text(
                              '${tips.length} optimization${tips.length != 1 ? 's' : ''} found',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : AppTheme.softBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tips list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: tips.length,
              itemBuilder: (context, index) {
                final tip = tips[index];
                return _buildTipCard(context, tip, isDark, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
      BuildContext context, Map<String, dynamic> tip, bool isDark, int index) {
    final theme = Theme.of(context);
    final tipType = tip['type'] as String;
    final tipColor = _getTipColor(tipType);
    final tipIcon = _getTipIcon(tipType);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tipColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x1A000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tipColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomIconWidget(
                  iconName: tipIcon,
                  color: tipColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getTipTypeLabel(tipType),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tipColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: tipColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Save ${tip['timeSaved']}min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tipColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            tip['description'],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.pureWhite.withValues(alpha: 0.8)
                  : AppTheme.textDark.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          if (tip['ingredients'] != null &&
              (tip['ingredients'] as List).isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              'Common Ingredients:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: (tip['ingredients'] as List).map((ingredient) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.backgroundDark : AppTheme.softBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.mediumGray.withValues(alpha: 0.3)
                          : AppTheme.lightGray,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ingredient,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (tip['recipes'] != null &&
              (tip['recipes'] as List).isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              'Affected Recipes:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Column(
              children: (tip['recipes'] as List).map((recipe) {
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: tipColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: tipColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'restaurant',
                        color: tipColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          recipe,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppTheme.pureWhite
                                : AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTipColor(String tipType) {
    switch (tipType) {
      case 'ingredient_prep':
        return AppTheme.primaryGreen;
      case 'cooking_method':
        return AppTheme.accentOrange;
      case 'storage':
        return Colors.deepPurple;
      case 'timing':
        return Colors.pink;
      default:
        return AppTheme.mediumGray;
    }
  }

  String _getTipIcon(String tipType) {
    switch (tipType) {
      case 'ingredient_prep':
        return 'kitchen';
      case 'cooking_method':
        return 'local_fire_department';
      case 'storage':
        return 'inventory_2';
      case 'timing':
        return 'schedule';
      default:
        return 'lightbulb';
    }
  }

  String _getTipTypeLabel(String tipType) {
    switch (tipType) {
      case 'ingredient_prep':
        return 'Ingredient Preparation';
      case 'cooking_method':
        return 'Cooking Method';
      case 'storage':
        return 'Storage Optimization';
      case 'timing':
        return 'Timing Strategy';
      default:
        return 'General Tip';
    }
  }
}