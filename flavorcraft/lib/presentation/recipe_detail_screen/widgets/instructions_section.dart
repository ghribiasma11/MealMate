import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_export.dart';

class InstructionsSection extends StatefulWidget {
  final List<Map<String, dynamic>> instructions;

  const InstructionsSection({
    super.key,
    required this.instructions,
  });

  @override
  State<InstructionsSection> createState() => _InstructionsSectionState();
}

class _InstructionsSectionState extends State<InstructionsSection>
    with TickerProviderStateMixin {
  Map<int, AnimationController> _stepControllers = {};
  Map<int, Animation<double>> _stepAnimations = {};
  Set<int> _completedSteps = {};

  @override
  void initState() {
    super.initState();

    // Initialize animations for each step
    for (int i = 0; i < widget.instructions.length; i++) {
      _stepControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _stepAnimations[i] = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(
        parent: _stepControllers[i]!,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    for (var controller in _stepControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleStepCompletion(int index) {
    HapticFeedback.lightImpact();

    setState(() {
      if (_completedSteps.contains(index)) {
        _completedSteps.remove(index);
        _stepControllers[index]?.reverse();
      } else {
        _completedSteps.add(index);
        _stepControllers[index]?.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'Instructions',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),

          SizedBox(height: 4.h),

          // Instructions List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.instructions.length,
            itemBuilder: (context, index) {
              final instruction = widget.instructions[index];
              final stepNumber = index + 1;
              final isCompleted = _completedSteps.contains(index);
              final stepText = instruction['text'] as String;
              final stepImage = instruction['image'] as String?;
              final stepTime = instruction['time'] as String?;

              return AnimatedBuilder(
                animation: _stepAnimations[index]!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _stepAnimations[index]!.value,
                    child: GestureDetector(
                      onTap: () => _toggleStepCompletion(index),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 4.h),
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.successGreen.withValues(alpha: 0.1)
                              : (isDark
                                  ? AppTheme.cardDark
                                  : AppTheme.cardWhite),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCompleted
                                ? AppTheme.successGreen.withValues(alpha: 0.3)
                                : (isDark
                                    ? AppTheme.mediumGray.withValues(alpha: 0.3)
                                    : AppTheme.lightGray),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : Colors.black)
                                  .withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Step Number
                                Container(
                                  width: 10.w,
                                  height: 10.w,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? AppTheme.successGreen
                                        : AppTheme.accentOrange,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: isCompleted
                                        ? CustomIconWidget(
                                            iconName: 'check',
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : Text(
                                            '$stepNumber',
                                            style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(width: 4.w),

                                // Step Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Step Text
                                      Text(
                                        stepText,
                                        style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isCompleted
                                              ? AppTheme.mediumGray
                                              : (isDark
                                                  ? Colors.white
                                                  : AppTheme.textDark),
                                          height: 1.4,
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),

                                      // Step Time
                                      if (stepTime != null) ...[
                                        SizedBox(height: 1.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 3.w, vertical: 1.h),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentOrange
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppTheme.accentOrange
                                                  .withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CustomIconWidget(
                                                iconName: 'timer',
                                                color: AppTheme.accentOrange,
                                                size: 16,
                                              ),
                                              SizedBox(width: 1.w),
                                              Text(
                                                stepTime,
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.accentOrange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Step Image
                            if (stepImage != null) ...[
                              SizedBox(height: 3.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CustomImageWidget(
                                  imageUrl: stepImage,
                                  width: double.infinity,
                                  height: 40.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}