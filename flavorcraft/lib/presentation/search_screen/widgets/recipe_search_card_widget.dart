import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class RecipeSearchCardWidget extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String searchQuery;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onAddToMealPlan;
  final VoidCallback? onShare;

  const RecipeSearchCardWidget({
    super.key,
    required this.recipe,
    this.searchQuery = '',
    this.onTap,
    this.onFavoritePressed,
    this.onAddToMealPlan,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showQuickActions(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.mediumGray : AppTheme.lightGray,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(isDark),
            _buildContentSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: CustomImageWidget(
            imageUrl: recipe['image'] as String,
            width: double.infinity,
            height: 20.h,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2.h,
          right: 3.w,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.textDark.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onFavoritePressed?.call();
              },
              child: CustomIconWidget(
                iconName: (recipe['isFavorite'] as bool? ?? false)
                    ? 'favorite'
                    : 'favorite_border',
                color: (recipe['isFavorite'] as bool? ?? false)
                    ? AppTheme.errorRed
                    : AppTheme.pureWhite,
                size: 20,
              ),
            ),
          ),
        ),
        if (recipe['relevanceScore'] != null)
          Positioned(
            top: 2.h,
            left: 3.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${((recipe['relevanceScore'] as double) * 100).toInt()}% match',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.pureWhite,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContentSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWithHighlight(isDark),
          SizedBox(height: 1.h),
          _buildRecipeInfo(isDark),
          SizedBox(height: 1.5.h),
          _buildMatchingIngredients(isDark),
          SizedBox(height: 1.5.h),
          _buildActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildTitleWithHighlight(bool isDark) {
    final title = recipe['title'] as String;
    
    if (searchQuery.isEmpty) {
      return Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Highlight matching text
    final lowerTitle = title.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    final startIndex = lowerTitle.indexOf(lowerQuery);

    if (startIndex == -1) {
      return Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: title.substring(0, startIndex),
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
            ),
          ),
          TextSpan(
            text: title.substring(startIndex, startIndex + searchQuery.length),
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentOrange,
              backgroundColor: AppTheme.accentOrange.withValues(alpha: 0.1),
            ),
          ),
          TextSpan(
            text: title.substring(startIndex + searchQuery.length),
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeInfo(bool isDark) {
    return Row(
      children: [
        _buildInfoChip(
          'timer',
          '${recipe['prepTime']} min',
          AppTheme.accentOrange,
        ),
        SizedBox(width: 2.w),
        _buildInfoChip(
          'star',
          recipe['difficulty'] as String,
          AppTheme.primaryGreen,
        ),
        SizedBox(width: 2.w),
        _buildInfoChip(
          'favorite',
          '${recipe['likes'] ?? 0}',
          AppTheme.errorRed,
        ),
      ],
    );
  }

  Widget _buildInfoChip(String icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 14,
          ),
          SizedBox(width: 1.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingIngredients(bool isDark) {
    final matchingIngredients = recipe['matchingIngredients'] as List<String>? ?? [];
    
    if (matchingIngredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matching ingredients:',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.mediumGray,
          ),
        ),
        SizedBox(height: 0.5.h),
        Wrap(
          spacing: 1.w,
          runSpacing: 0.5.h,
          children: matchingIngredients.take(3).map((ingredient) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accentOrange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                ingredient,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accentOrange,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          recipe['category'] as String,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.accentOrange,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onAddToMealPlan?.call();
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.primaryGreen,
                  size: 16,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onShare?.call();
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.mediumGray.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'share',
                  color: AppTheme.mediumGray,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.cardDark
              : AppTheme.pureWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.mediumGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            _buildQuickActionItem(
              'Add to Favorites',
              'favorite',
              AppTheme.errorRed,
              onFavoritePressed,
            ),
            _buildQuickActionItem(
              'Add to Meal Plan',
              'calendar_today',
              AppTheme.primaryGreen,
              onAddToMealPlan,
            ),
            _buildQuickActionItem(
              'Share Recipe',
              'share',
              AppTheme.mediumGray,
              onShare,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    String title,
    String icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.pureWhite
                      : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
