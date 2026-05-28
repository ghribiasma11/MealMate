import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class StoreOptimizationDialog extends StatefulWidget {
  final Function(String) onStoreSelected;

  const StoreOptimizationDialog({
    super.key,
    required this.onStoreSelected,
  });

  @override
  State<StoreOptimizationDialog> createState() =>
      _StoreOptimizationDialogState();
}

class _StoreOptimizationDialogState extends State<StoreOptimizationDialog> {
  String _selectedStore = 'Generic Grocery Store';

  final List<Map<String, dynamic>> _storeLayouts = [
    {
      'name': 'Generic Grocery Store',
      'icon': 'store',
      'description':
          'Standard layout: Produce → Dairy → Meat → Pantry → Frozen',
      'color': AppTheme.mediumGray,
    },
    {
      'name': 'Walmart',
      'icon': 'local_grocery_store',
      'description':
          'Walmart layout: Produce → Bakery → Dairy → Meat → Pantry → Frozen',
      'color': AppTheme.accentOrange,
    },
    {
      'name': 'Target',
      'icon': 'shopping_cart',
      'description':
          'Target layout: Produce → Dairy → Frozen → Meat → Pantry → Bakery',
      'color': AppTheme.errorRed,
    },
    {
      'name': 'Whole Foods',
      'icon': 'eco',
      'description':
          'Whole Foods layout: Produce → Bakery → Dairy → Meat → Pantry → Frozen',
      'color': AppTheme.primaryGreen,
    },
    {
      'name': 'Costco',
      'icon': 'warehouse',
      'description':
          'Costco layout: Produce → Meat → Dairy → Frozen → Pantry → Bakery',
      'color': AppTheme.cardDark,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: 70.h),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'store',
                      color: AppTheme.accentOrange,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Optimize for Store',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppTheme.pureWhite
                                : AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Reorder items by store layout',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.mediumGray,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(4.w),
                itemCount: _storeLayouts.length,
                itemBuilder: (context, index) {
                  final store = _storeLayouts[index];
                  final isSelected = _selectedStore == store['name'];

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedStore = store['name'] as String;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (store['color'] as Color).withValues(alpha: 0.1)
                            : (isDark
                                ? AppTheme.cardDark
                                : AppTheme.lightGray.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (store['color'] as Color)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (store['color'] as Color)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomIconWidget(
                              iconName: store['icon'] as String,
                              color: store['color'] as Color,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store['name'] as String,
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
                                  store['description'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.mediumGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: store['color'] as Color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CustomIconWidget(
                                iconName: 'check',
                                color: AppTheme.pureWhite,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onStoreSelected(_selectedStore);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply Layout',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}