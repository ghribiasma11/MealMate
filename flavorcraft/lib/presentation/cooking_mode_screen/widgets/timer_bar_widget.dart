import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class TimerBarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activeTimers;
  final VoidCallback? onTimerTap;

  const TimerBarWidget({
    super.key,
    required this.activeTimers,
    this.onTimerTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (activeTimers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.black).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'timer',
                color: AppTheme.accentOrange,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Active Timers',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 8.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: activeTimers.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final timer = activeTimers[index];
                final progress = (timer['progress'] as double?) ?? 0.0;
                final timeRemaining =
                    timer['timeRemaining'] as String? ?? '00:00';
                final timerName =
                    timer['name'] as String? ?? 'Timer ${index + 1}';
                final timerColor = _getTimerColor(index);

                return GestureDetector(
                  onTap: onTimerTap,
                  child: Container(
                    width: 20.w,
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: timerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: timerColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 8.w,
                              height: 8.w,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 3,
                                backgroundColor:
                                    timerColor.withValues(alpha: 0.2),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(timerColor),
                              ),
                            ),
                            CustomIconWidget(
                              iconName: 'timer',
                              color: timerColor,
                              size: 16,
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          timeRemaining,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: timerColor,
                          ),
                        ),
                        Text(
                          timerName,
                          style: GoogleFonts.inter(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppTheme.pureWhite
                                : AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor(int index) {
    final colors = [
      AppTheme.accentOrange,
      AppTheme.successGreen,
      Colors.deepPurple,
      Colors.pink,
      AppTheme.errorRed,
    ];
    return colors[index % colors.length];
  }
}