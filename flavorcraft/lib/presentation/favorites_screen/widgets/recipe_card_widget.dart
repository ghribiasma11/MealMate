import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecipeCardWidget extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final bool isGridView;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSelectionToggle;

  const RecipeCardWidget({
    super.key,
    required this.recipe,
    this.isGridView = true,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onFavoriteToggle,
    this.onMenuTap,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isSelectionMode) {
          onSelectionToggle?.call();
        } else {
          onTap?.call();
        }
      },
      onLongPress: isSelectionMode
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onSelectionToggle?.call();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          horizontal: isGridView ? 1.w : 4.w,
          vertical: 1.h,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppTheme.accentOrange, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color:
                  (isDark ? Colors.black : Colors.black).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isGridView ? _buildGridCard(isDark) : _buildListCard(isDark),
      ),
    );
  }

  Widget _buildGridCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(isDark, isGrid: true),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(isDark),
                SizedBox(height: 1.5.h),
                _buildMetadata(isDark),
                SizedBox(height: 1.5.h),
                _buildActions(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(bool isDark) {
    return Row(
      children: [
        _buildImageSection(isDark, isGrid: false),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(isDark),
                SizedBox(height: 1.h),
                _buildMetadata(isDark),
                SizedBox(height: 1.h),
                _buildDescription(isDark),
                SizedBox(height: 1.h),
                _buildActions(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(bool isDark, {required bool isGrid}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomImageWidget(
            imageUrl: recipe["image"] as String,
            width: isGrid ? double.infinity : 25.w,
            height: isGrid ? 20.h : 15.h,
            fit: BoxFit.cover,
          ),
        ),
        if (isSelectionMode)
          Positioned(
            top: 8,
            left: 8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentOrange : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppTheme.accentOrange : AppTheme.lightGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
        if (!isSelectionMode && recipe["rating"] != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.accentOrange,
                    size: 12,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    recipe["rating"].toString(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      recipe["title"] as String,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppTheme.textDark,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'access_time',
              color: AppTheme.mediumGray,
              size: 14,
            ),
            SizedBox(width: 1.w),
            Text(
              recipe["prepTime"] as String,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.8.h),
        _buildDifficultyChip(),
      ],
    );
  }

  Widget _buildDifficultyChip() {
    final difficulty = recipe["difficulty"] as String;
    Color chipColor;

    switch (difficulty.toLowerCase()) {
      case 'easy':
        chipColor = AppTheme.successGreen;
        break;
      case 'medium':
        chipColor = AppTheme.accentOrange;
        break;
      case 'hard':
        chipColor = AppTheme.errorRed;
        break;
      default:
        chipColor = AppTheme.mediumGray;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        difficulty,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Text(
      recipe["description"] as String,
      style: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.mediumGray,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActions(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'people',
              color: AppTheme.mediumGray,
              size: 14,
            ),
            SizedBox(width: 1.w),
            Text(
              '${recipe["servings"]} servings',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
        if (!isSelectionMode)
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onFavoriteToggle?.call();
                },
                child: Container(
                  padding: EdgeInsets.all(1.w),
                    child: CustomIconWidget(
                      iconName: (recipe["isFavorite"] as bool? ?? true)
                          ? 'favorite'
                          : 'favorite_border',
                      color: AppTheme.errorRed,
                      size: 18,
                    ),
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onMenuTap?.call();
                },
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  child: CustomIconWidget(
                    iconName: 'more_vert',
                    color: AppTheme.mediumGray,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
