import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class CookingStepCardWidget extends StatelessWidget {
  final Map<String, dynamic> currentStep;
  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onStartTimer;

  const CookingStepCardWidget({
    super.key,
    required this.currentStep,
    required this.currentStepIndex,
    required this.totalSteps,
    this.onPrevious,
    this.onNext,
    this.onStartTimer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stepNumber = currentStepIndex + 1;
    final instruction = currentStep['instruction'] as String? ?? '';
    final imageUrl = currentStep['image'] as String?;
    final timerDuration = currentStep['timer'] as String?;
    final tips = currentStep['tips'] as String?;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: isDark ? AppTheme.cardDark : AppTheme.cardWhite,
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step header
              Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        stepNumber.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.pureWhite,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step $stepNumber of $totalSteps',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        LinearProgressIndicator(
                          value: stepNumber / totalSteps,
                          backgroundColor: AppTheme.lightGray,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentOrange),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Step image if available
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 25.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 2.h),
              ],

              // Step instruction
              Text(
                instruction,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                  height: 1.5,
                ),
              ),

              // Timer section
              if (timerDuration != null) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentOrange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'timer',
                        color: AppTheme.accentOrange,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Timer: $timerDuration',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onStartTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentOrange,
                          foregroundColor: AppTheme.pureWhite,
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Start Timer',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Tips section
              if (tips != null) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.successGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb',
                        color: AppTheme.successGreen,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chef\'s Tip',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.successGreen,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              tips,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? AppTheme.pureWhite
                                    : AppTheme.textDark,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 3.h),

              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentStepIndex > 0 ? onPrevious : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppTheme.cardDark : AppTheme.softBackground,
                        foregroundColor:
                            isDark ? AppTheme.pureWhite : AppTheme.textDark,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'arrow_back',
                            color: currentStepIndex > 0
                                ? (isDark
                                    ? AppTheme.pureWhite
                                    : AppTheme.textDark)
                                : AppTheme.mediumGray,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Previous',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          currentStepIndex < totalSteps - 1 ? onNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: AppTheme.pureWhite,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentStepIndex < totalSteps - 1
                                ? 'Next'
                                : 'Complete',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: currentStepIndex < totalSteps - 1
                                ? 'arrow_forward'
                                : 'check',
                            color: AppTheme.pureWhite,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
