import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class EmptySearchWidget extends StatelessWidget {
  final String searchQuery;
  final List<String> trendingRecipes;
  final ValueChanged<String>? onTrendingTap;
  final VoidCallback? onClearFilters;
  final bool hasActiveFilters;

  const EmptySearchWidget({
    super.key,
    this.searchQuery = '',
    required this.trendingRecipes,
    this.onTrendingTap,
    this.onClearFilters,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          _buildIllustration(isDark),
          SizedBox(height: 4.h),
          _buildTitle(isDark),
          SizedBox(height: 2.h),
          _buildDescription(isDark),
          if (hasActiveFilters) ...[
            SizedBox(height: 3.h),
            _buildClearFiltersButton(isDark),
          ],
          SizedBox(height: 4.h),
          _buildTrendingSection(isDark),
          SizedBox(height: 3.h),
          _buildSearchTips(isDark),
        ],
      ),
    );
  }

  Widget _buildIllustration(bool isDark) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: searchQuery.isEmpty ? 'search' : 'search_off',
          color: AppTheme.accentOrange,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    String title;
    if (searchQuery.isEmpty) {
      title = 'Discover Amazing Recipes';
    } else {
      title = 'No recipes found';
    }

    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(bool isDark) {
    String description;
    if (searchQuery.isEmpty) {
      description =
          'Start typing to search for recipes, ingredients, or cooking techniques';
    } else {
      description =
          'Try adjusting your search terms or filters to find what you\'re looking for';
    }

    return Text(
      description,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.mediumGray,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildClearFiltersButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onClearFilters?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.accentOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.accentOrange,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'clear_all',
              color: AppTheme.accentOrange,
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              'Clear all filters',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(bool isDark) {
    if (trendingRecipes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'trending_up',
              color: AppTheme.accentOrange,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Trending Recipes',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: trendingRecipes.take(6).map((recipe) {
            return _buildTrendingChip(recipe, isDark);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTrendingChip(String recipe, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTrendingTap?.call(recipe);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.softBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.mediumGray : AppTheme.lightGray,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'local_fire_department',
              color: AppTheme.accentOrange,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              recipe,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTips(bool isDark) {
    const tips = [
      'Try searching for specific ingredients like "chicken" or "tomato"',
      'Look for cooking methods like "grilled" or "baked"',
      'Search by cuisine type like "Italian" or "Asian"',
      'Use dietary preferences like "vegetarian" or "gluten-free"',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'lightbulb',
              color: AppTheme.successGreen,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Search Tips',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ...tips.map((tip) => _buildTipItem(tip, isDark)).toList(),
      ],
    );
  }

  Widget _buildTipItem(String tip, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 1.w,
            height: 1.w,
            decoration: BoxDecoration(
              color: AppTheme.mediumGray,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.mediumGray,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}