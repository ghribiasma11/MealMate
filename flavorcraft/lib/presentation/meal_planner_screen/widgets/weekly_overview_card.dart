import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeeklyOverviewCard extends StatelessWidget {
  final int totalPrepTime;
  final int ingredientOverlaps;
  final List<String> batchCookingTips;
  final VoidCallback? onGenerateShoppingList;
  final VoidCallback? onViewBatchTips;

  const WeeklyOverviewCard({
    super.key,
    required this.totalPrepTime,
    required this.ingredientOverlaps,
    required this.batchCookingTips,
    this.onGenerateShoppingList,
    this.onViewBatchTips,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x1A000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.accentOrange,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Weekly Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Prep Time',
                  '${totalPrepTime}min',
                  CustomIconWidget(
                    iconName: 'timer',
                    color: AppTheme.accentOrange,
                    size: 20,
                  ),
                  isDark,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Ingredient Overlaps',
                  '$ingredientOverlaps items',
                  CustomIconWidget(
                    iconName: 'inventory_2',
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                  isDark,
                ),
              ),
            ],
          ),
          if (batchCookingTips.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'lightbulb',
                      color: AppTheme.pureWhite,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batch Cooking Opportunities',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${batchCookingTips.length} optimization${batchCookingTips.length != 1 ? 's' : ''} available',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewBatchTips,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'View Tips',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.pureWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGenerateShoppingList,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                foregroundColor: AppTheme.pureWhite,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'shopping_cart',
                    color: AppTheme.pureWhite,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Generate Shopping List',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.pureWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Widget icon,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.softBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppTheme.mediumGray.withValues(alpha: 0.3)
              : AppTheme.lightGray,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}