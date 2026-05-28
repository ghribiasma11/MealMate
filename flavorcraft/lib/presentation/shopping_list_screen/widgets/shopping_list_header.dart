import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class ShoppingListHeader extends StatelessWidget {
  final int totalItems;
  final int completedItems;
  final VoidCallback onShare;
  final VoidCallback onClearAll;
  final VoidCallback onOptimizeStore;

  const ShoppingListHeader({
    super.key,
    required this.totalItems,
    required this.completedItems,
    required this.onShare,
    required this.onClearAll,
    required this.onOptimizeStore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressPercentage =
        totalItems > 0 ? (completedItems / totalItems) : 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.black).withValues(alpha: 0.05),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shopping List',
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '$totalItems items${completedItems > 0 ? ' • $completedItems completed' : ''}',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onShare();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentOrange.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'share',
                        color: AppTheme.accentOrange,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      HapticFeedback.lightImpact();
                      switch (value) {
                        case 'clear':
                          onClearAll();
                          break;
                        case 'optimize':
                          onOptimizeStore();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'optimize',
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'store',
                              color: AppTheme.successGreen,
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Optimize for Store',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'clear_all',
                              color: AppTheme.errorRed,
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Clear All',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.cardDark
                            : AppTheme.lightGray.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'more_vert',
                        color: AppTheme.mediumGray,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (totalItems > 0) ...[
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentOrange.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentOrange,
                        ),
                      ),
                      Text(
                        '${(progressPercentage * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}