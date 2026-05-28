import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class ShoppingCategorySection extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> items;
  final Function(String, int) onItemToggle;
  final Function(String, int) onItemDelete;
  final bool isExpanded;
  final Function(String) onToggleExpanded;

  const ShoppingCategorySection({
    super.key,
    required this.categoryName,
    required this.items,
    required this.onItemToggle,
    required this.onItemDelete,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  State<ShoppingCategorySection> createState() =>
      _ShoppingCategorySectionState();
}

class _ShoppingCategorySectionState extends State<ShoppingCategorySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ShoppingCategorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    switch (widget.categoryName.toLowerCase()) {
      case 'produce':
        return AppTheme.primaryGreen;
      case 'dairy':
        return AppTheme.accentOrange;
      case 'meat':
        return AppTheme.errorRed;
      case 'pantry':
        return AppTheme.cardDark;
      case 'bakery':
        return AppTheme.accentOrange;
      case 'frozen':
        return const Color(0xFF0EA5E9);
      default:
        return AppTheme.mediumGray;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.categoryName.toLowerCase()) {
      case 'produce':
        return Icons.eco;
      case 'dairy':
        return Icons.local_drink;
      case 'meat':
        return Icons.restaurant;
      case 'pantry':
        return Icons.kitchen;
      case 'bakery':
        return Icons.cake;
      case 'frozen':
        return Icons.ac_unit;
      default:
        return Icons.shopping_basket;
    }
  }

  int get _checkedItemsCount {
    return (widget.items as List)
        .where((item) => (item as Map<String, dynamic>)["isChecked"] as bool)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = _getCategoryColor();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onToggleExpanded(widget.categoryName);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: widget.isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getCategoryIcon().codePoint.toString(),
                      color: categoryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.pureWhite
                                : AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${widget.items.length} items${_checkedItemsCount > 0 ? ' • $_checkedItemsCount completed' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  ...widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isChecked = item["isChecked"] as bool;

                    return Dismissible(
                      key: Key('${widget.categoryName}_$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'delete',
                          color: AppTheme.errorRed,
                          size: 24,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        HapticFeedback.mediumImpact();
                        return true;
                      },
                      onDismissed: (direction) {
                        widget.onItemDelete(widget.categoryName, index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item["name"]} removed from list'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // Undo functionality would be handled by parent
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 1.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? categoryColor.withValues(alpha: 0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isChecked
                                ? categoryColor.withValues(alpha: 0.3)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onItemToggle(widget.categoryName, index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? categoryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isChecked
                                        ? categoryColor
                                        : AppTheme.lightGray,
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
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["name"] as String,
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
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  if (item["quantity"] != null &&
                                      item["unit"] != null) ...[
                                    SizedBox(height: 0.5.h),
                                    Row(
                                      children: [
                                        Text(
                                          '${item["quantity"]} ${item["unit"]}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppTheme.mediumGray,
                                            decoration: isChecked
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                        if (item["consolidated"] == true) ...[
                                          SizedBox(width: 2.w),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.successGreen
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Combined',
                                              style: GoogleFonts.inter(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.successGreen,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                  if (item["recipes"] != null &&
                                      (item["recipes"] as List).length > 1) ...[
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'From ${(item["recipes"] as List).length} recipes',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w400,
                                        color: categoryColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (item["recipes"] != null &&
                                (item["recipes"] as List).length > 1)
                              CustomIconWidget(
                                iconName: 'info_outline',
                                color: AppTheme.mediumGray,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}