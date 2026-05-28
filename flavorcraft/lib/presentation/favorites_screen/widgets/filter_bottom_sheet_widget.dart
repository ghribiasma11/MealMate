import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  late RangeValues _prepTimeRange;

  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Desserts',
    'Beverages',
    'Snacks',
  ];

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _prepTimeRange = RangeValues(
      (_filters['minPrepTime'] as double?) ?? 0.0,
      (_filters['maxPrepTime'] as double?) ?? 120.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isDark),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySection(isDark),
                  SizedBox(height: 3.h),
                  _buildPrepTimeSection(isDark),
                  SizedBox(height: 3.h),
                  _buildDifficultySection(isDark),
                  SizedBox(height: 4.h),
                  _buildActionButtons(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppTheme.mediumGray.withValues(alpha: 0.3)
                : AppTheme.lightGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter Recipes',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.mediumGray.withValues(alpha: 0.2)
                    : AppTheme.lightGray.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: isDark ? Colors.white : AppTheme.textDark,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _categories.map((category) {
            final isSelected =
                (_filters['categories'] as List<String>?)?.contains(category) ??
                    false;
            return _buildCategoryChip(category, isSelected, isDark);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected, bool isDark) {
    final categoryColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          final categories =
              (_filters['categories'] as List<String>?) ?? <String>[];
          if (category == 'All') {
            _filters['categories'] =
                categories.contains('All') ? <String>[] : ['All'];
          } else {
            final newCategories = List<String>.from(categories);
            newCategories.remove('All');
            if (newCategories.contains(category)) {
              newCategories.remove(category);
            } else {
              newCategories.add(category);
            }
            _filters['categories'] = newCategories;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? categoryColor.withValues(alpha: 0.1)
              : (isDark ? AppTheme.cardDark : AppTheme.softBackground),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? categoryColor
                : (isDark ? AppTheme.mediumGray : AppTheme.lightGray),
            width: 1,
          ),
        ),
        child: Text(
          category,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? categoryColor
                : (isDark ? Colors.white : AppTheme.textDark),
          ),
        ),
      ),
    );
  }

  Widget _buildPrepTimeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preparation Time',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          '${_prepTimeRange.start.round()} - ${_prepTimeRange.end.round()} minutes',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.accentOrange,
          ),
        ),
        SizedBox(height: 2.h),
        RangeSlider(
          values: _prepTimeRange,
          min: 0,
          max: 120,
          divisions: 24,
          activeColor: AppTheme.accentOrange,
          inactiveColor: isDark ? AppTheme.mediumGray : AppTheme.lightGray,
          onChanged: (RangeValues values) {
            setState(() {
              _prepTimeRange = values;
              _filters['minPrepTime'] = values.start;
              _filters['maxPrepTime'] = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDifficultySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Level',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children: _difficulties.map((difficulty) {
            final isSelected = (_filters['difficulties'] as List<String>?)
                    ?.contains(difficulty) ??
                false;
            return _buildDifficultyTile(difficulty, isSelected, isDark);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultyTile(String difficulty, bool isSelected, bool isDark) {
    final difficultyColor = _getDifficultyColor(difficulty);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          final difficulties =
              (_filters['difficulties'] as List<String>?) ?? <String>[];
          final newDifficulties = List<String>.from(difficulties);
          if (newDifficulties.contains(difficulty)) {
            newDifficulties.remove(difficulty);
          } else {
            newDifficulties.add(difficulty);
          }
          _filters['difficulties'] = newDifficulties;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? difficultyColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? difficultyColor
                : (isDark
                    ? AppTheme.mediumGray.withValues(alpha: 0.3)
                    : AppTheme.lightGray),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? difficultyColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? difficultyColor : AppTheme.mediumGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            SizedBox(width: 3.w),
            Text(
              difficulty,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _filters = {
                  'categories': <String>[],
                  'minPrepTime': 0.0,
                  'maxPrepTime': 120.0,
                  'difficulties': <String>[],
                };
                _prepTimeRange = const RangeValues(0.0, 120.0);
              });
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              side: BorderSide(color: AppTheme.mediumGray, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.mediumGray,
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onFiltersChanged(_filters);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Apply Filters',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return AppTheme.accentOrange;
      case 'lunch':
      case 'dinner':
        return AppTheme.primaryGreen;
      case 'desserts':
        return AppTheme.cardDark;
      case 'beverages':
        return AppTheme.errorRed;
      case 'snacks':
        return AppTheme.accentOrange;
      default:
        return AppTheme.mediumGray;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.primaryGreen;
      case 'medium':
        return AppTheme.accentOrange;
      case 'hard':
        return AppTheme.errorRed;
      default:
        return AppTheme.mediumGray;
    }
  }
}
