import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchFiltersWidget extends StatelessWidget {
  final List<String> selectedFilters;
  final ValueChanged<String>? onFilterToggle;
  final VoidCallback? onAdvancedFilters;
  final int activeFilterCount;

  const SearchFiltersWidget({
    super.key,
    required this.selectedFilters,
    this.onFilterToggle,
    this.onAdvancedFilters,
    this.activeFilterCount = 0,
  });

  static const List<Map<String, dynamic>> _filterOptions = [
    {'label': 'Quick', 'value': 'quick', 'icon': 'timer'},
    {'label': 'Healthy', 'value': 'healthy', 'icon': 'eco'},
    {'label': 'Vegan', 'value': 'vegan', 'icon': 'local_florist'},
    {'label': 'Easy', 'value': 'easy', 'icon': 'star'},
    {'label': 'Popular', 'value': 'popular', 'icon': 'trending_up'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 8.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  ..._filterOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final filter = entry.value;
                    final isSelected =
                        selectedFilters.contains(filter['value']);
                    final isLastItem = index == _filterOptions.length - 1;

                    return Container(
                      margin: EdgeInsets.only(right: isLastItem ? 0 : 3.w),
                      child: _buildFilterChip(
                        filter['label'],
                        filter['value'],
                        filter['icon'],
                        isSelected,
                        isDark,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 2.w, right: 4.w),
            child: _buildAdvancedFilterButton(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String icon,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onFilterToggle?.call(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentOrange
              : (isDark ? AppTheme.cardDark : AppTheme.softBackground),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentOrange
                : (isDark ? AppTheme.mediumGray : AppTheme.lightGray),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentOrange.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isSelected
                  ? AppTheme.pureWhite
                  : (isDark ? AppTheme.mediumGray : AppTheme.mediumGray),
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppTheme.pureWhite
                    : (isDark ? AppTheme.pureWhite : AppTheme.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilterButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onAdvancedFilters?.call();
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: activeFilterCount > 0
              ? AppTheme.accentOrange.withValues(alpha: 0.15)
              : (isDark ? AppTheme.cardDark : AppTheme.softBackground),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: activeFilterCount > 0
                ? AppTheme.accentOrange
                : (isDark ? AppTheme.mediumGray : AppTheme.lightGray),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            CustomIconWidget(
              iconName: 'tune',
              color: activeFilterCount > 0
                  ? AppTheme.accentOrange
                  : (isDark ? AppTheme.mediumGray : AppTheme.mediumGray),
              size: 22,
            ),
            if (activeFilterCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 5.w,
                    minHeight: 5.w,
                  ),
                  child: Text(
                    activeFilterCount.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.pureWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}