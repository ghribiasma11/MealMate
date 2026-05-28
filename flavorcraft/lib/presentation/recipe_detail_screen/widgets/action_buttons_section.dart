import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ActionButtonsSection extends StatefulWidget {
  final VoidCallback onStartCooking;
  final VoidCallback onAddToMealPlan;
  final VoidCallback onGenerateShoppingList;

  const ActionButtonsSection({
    super.key,
    required this.onStartCooking,
    required this.onAddToMealPlan,
    required this.onGenerateShoppingList,
  });

  @override
  State<ActionButtonsSection> createState() => _ActionButtonsSectionState();
}

class _ActionButtonsSectionState extends State<ActionButtonsSection>
    with TickerProviderStateMixin {
  late AnimationController _primaryButtonController;
  late AnimationController _secondaryButtonController;
  late Animation<double> _primaryButtonAnimation;
  late Animation<double> _secondaryButtonAnimation;

  @override
  void initState() {
    super.initState();

    _primaryButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _secondaryButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _primaryButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _primaryButtonController,
      curve: Curves.easeInOut,
    ));

    _secondaryButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _secondaryButtonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _primaryButtonController.dispose();
    _secondaryButtonController.dispose();
    super.dispose();
  }

  void _onPrimaryButtonPressed() {
    HapticFeedback.mediumImpact();
    _primaryButtonController.forward().then((_) {
      _primaryButtonController.reverse();
    });
    widget.onStartCooking();
  }

  void _onSecondaryButtonPressed(VoidCallback callback) {
    HapticFeedback.lightImpact();
    _secondaryButtonController.forward().then((_) {
      _secondaryButtonController.reverse();
    });
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.black).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary Action Button - Start Cooking
            AnimatedBuilder(
              animation: _primaryButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _primaryButtonAnimation.value,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentOrange,
                          AppTheme.accentOrange.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentOrange.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _onPrimaryButtonPressed,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'play_arrow',
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Start Cooking',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 2.h),

            // Secondary Action Buttons
            AnimatedBuilder(
              animation: _secondaryButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _secondaryButtonAnimation.value,
                  child: Row(
                    children: [
                      // Add to Meal Plan Button
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onSecondaryButtonPressed(
                                  widget.onAddToMealPlan),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'calendar_today',
                                      color: AppTheme.primaryGreen,
                                      size: 16,
                                    ),
                                    SizedBox(width: 1.w),
                                    Flexible(
                                      child: Text(
                                        'Add to Plan',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primaryGreen,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 3.w),

                      // Generate Shopping List Button
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.mediumGray.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.mediumGray.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onSecondaryButtonPressed(
                                  widget.onGenerateShoppingList),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'shopping_cart',
                                      color: AppTheme.mediumGray,
                                      size: 16,
                                    ),
                                    SizedBox(width: 1.w),
                                    Flexible(
                                      child: Text(
                                        'Shopping List',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.mediumGray,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}