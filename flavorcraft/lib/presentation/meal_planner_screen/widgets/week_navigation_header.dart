import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeekNavigationHeader extends StatelessWidget {
  final DateTime currentWeekStart;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;
  final VoidCallback? onTodayPressed;

  const WeekNavigationHeader({
    super.key,
    required this.currentWeekStart,
    this.onPreviousWeek,
    this.onNextWeek,
    this.onTodayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weekEnd = currentWeekStart.add(const Duration(days: 6));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x1A000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onPreviousWeek?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : AppTheme.softBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.mediumGray.withValues(alpha: 0.3)
                            : AppTheme.lightGray,
                        width: 1,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'chevron_left',
                      color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                      size: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _formatWeekRange(currentWeekStart, weekEnd),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppTheme.pureWhite : AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 0.5.h),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTodayPressed?.call();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  AppTheme.accentOrange.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'today',
                                color: AppTheme.accentOrange,
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Today',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.accentOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onNextWeek?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : AppTheme.softBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.mediumGray.withValues(alpha: 0.3)
                            : AppTheme.lightGray,
                        width: 1,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildDayHeaders(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeaders(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();

    return Row(
      children: days.asMap().entries.map((entry) {
        final index = entry.key;
        final dayName = entry.value;
        final dayDate = currentWeekStart.add(Duration(days: index));
        final isToday = dayDate.day == today.day &&
            dayDate.month == today.month &&
            dayDate.year == today.year;

        return Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.accentOrange.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(
                      color: AppTheme.accentOrange.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  dayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        isToday ? AppTheme.accentOrange : AppTheme.mediumGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${dayDate.day}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? AppTheme.accentOrange
                        : (isDark ? AppTheme.pureWhite : AppTheme.textDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    if (start.month == end.month) {
      return '${months[start.month - 1]} ${start.day} - ${end.day}, ${start.year}';
    } else {
      return '${months[start.month - 1]} ${start.day} - ${months[end.month - 1]} ${end.day}, ${start.year}';
    }
  }
}