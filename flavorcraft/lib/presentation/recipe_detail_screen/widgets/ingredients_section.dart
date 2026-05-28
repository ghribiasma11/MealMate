import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_export.dart';

class IngredientsSection extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  final int servingSize;
  final int originalServingSize;
  final bool isMetric;
  final ValueChanged<bool> onUnitToggle;
  final Set<int> checkedIngredients;
  final ValueChanged<Set<int>> onIngredientsChanged;

  const IngredientsSection({
    super.key,
    required this.ingredients,
    required this.servingSize,
    required this.originalServingSize,
    required this.isMetric,
    required this.onUnitToggle,
    required this.checkedIngredients,
    required this.onIngredientsChanged,
  });

  @override
  State<IngredientsSection> createState() => _IngredientsSectionState();
}

class _IngredientsSectionState extends State<IngredientsSection>
    with TickerProviderStateMixin {
  late AnimationController _toggleController;
  late Animation<double> _toggleAnimation;
  Map<int, AnimationController> _checkControllers = {};
  Map<int, Animation<double>> _checkAnimations = {};

  @override
  void initState() {
    super.initState();
    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _toggleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    ));

    // Initialize check animations for each ingredient
    for (int i = 0; i < widget.ingredients.length; i++) {
      _checkControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _checkAnimations[i] = Tween<double>(
        begin: 1.0,
        end: 0.6,
      ).animate(CurvedAnimation(
        parent: _checkControllers[i]!,
        curve: Curves.easeInOut,
      ));
    }

    if (widget.isMetric) {
      _toggleController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _toggleController.dispose();
    for (var controller in _checkControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleUnit() {
    HapticFeedback.lightImpact();
    if (widget.isMetric) {
      _toggleController.reverse();
    } else {
      _toggleController.forward();
    }
    widget.onUnitToggle(!widget.isMetric);
  }

  void _toggleIngredient(int index) {
    HapticFeedback.lightImpact();
    final newChecked = Set<int>.from(widget.checkedIngredients);

    if (newChecked.contains(index)) {
      newChecked.remove(index);
      _checkControllers[index]?.reverse();
    } else {
      newChecked.add(index);
      _checkControllers[index]?.forward();
    }

    widget.onIngredientsChanged(newChecked);
  }

  void _copyIngredientToClipboard(String ingredient) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: ingredient));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ingredient copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _convertQuantity(double quantity, String unit) {
    final multiplier = widget.servingSize / widget.originalServingSize;
    final adjustedQuantity = quantity * multiplier;

    if (!widget.isMetric) {
      // Convert to imperial if needed
      switch (unit.toLowerCase()) {
        case 'ml':
          return '${(adjustedQuantity * 0.033814).toStringAsFixed(1)} fl oz';
        case 'l':
          return '${(adjustedQuantity * 33.814).toStringAsFixed(1)} fl oz';
        case 'g':
          return '${(adjustedQuantity * 0.035274).toStringAsFixed(1)} oz';
        case 'kg':
          return '${(adjustedQuantity * 2.20462).toStringAsFixed(1)} lbs';
        default:
          return '${adjustedQuantity.toStringAsFixed(adjustedQuantity == adjustedQuantity.roundToDouble() ? 0 : 1)} $unit';
      }
    }

    return '${adjustedQuantity.toStringAsFixed(adjustedQuantity == adjustedQuantity.roundToDouble() ? 0 : 1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Unit Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ingredients',
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              GestureDetector(
                onTap: _toggleUnit,
                child: AnimatedBuilder(
                  animation: _toggleAnimation,
                  builder: (context, child) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accentOrange.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Imperial',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: _toggleAnimation.value < 0.5
                                  ? AppTheme.accentOrange
                                  : AppTheme.mediumGray,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            width: 12.w,
                            height: 3.h,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  left: _toggleAnimation.value * 6.w,
                                  top: 0.5.h,
                                  child: Container(
                                    width: 5.w,
                                    height: 2.h,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentOrange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Metric',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: _toggleAnimation.value >= 0.5
                                  ? AppTheme.accentOrange
                                  : AppTheme.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Ingredients List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = widget.ingredients[index];
              final isChecked = widget.checkedIngredients.contains(index);
              final quantity = ingredient['quantity'] as double? ?? 0.0;
              final unit = ingredient['unit'] as String? ?? '';
              final name = ingredient['name'] as String;

              return AnimatedBuilder(
                animation: _checkAnimations[index]!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _checkAnimations[index]!.value,
                    child: GestureDetector(
                      onTap: () => _toggleIngredient(index),
                      onLongPress: () => _copyIngredientToClipboard(
                          '${_convertQuantity(quantity, unit)} $name'),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? AppTheme.successGreen.withValues(alpha: 0.1)
                              : (isDark
                                  ? AppTheme.cardDark
                                  : AppTheme.softBackground),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isChecked
                                ? AppTheme.successGreen.withValues(alpha: 0.3)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Checkbox
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? AppTheme.successGreen
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isChecked
                                      ? AppTheme.successGreen
                                      : AppTheme.mediumGray,
                                  width: 2,
                                ),
                              ),
                              child: isChecked
                                  ? CustomIconWidget(
                                      iconName: 'check',
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),

                            SizedBox(width: 4.w),

                            // Ingredient Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (quantity > 0) ...[
                                    Text(
                                      _convertQuantity(quantity, unit),
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accentOrange,
                                        decoration: isChecked
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                  ],
                                  Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isChecked
                                          ? AppTheme.mediumGray
                                          : (isDark
                                              ? Colors.white
                                              : AppTheme.textDark),
                                      decoration: isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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