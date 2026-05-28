import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onExploreRecipes;

  const EmptyStateWidget({
    super.key,
    this.onExploreRecipes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(isDark),
            SizedBox(height: 4.h),
            _buildTitle(isDark),
            SizedBox(height: 2.h),
            _buildDescription(isDark),
            SizedBox(height: 4.h),
            _buildActionButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(bool isDark) {
    return Container(
      width: 60.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentOrange.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'favorite_border',
              color: AppTheme.accentOrange,
              size: 40,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFloatingIcon('restaurant', AppTheme.primaryGreen),
              _buildFloatingIcon('cake', Colors.deepPurple),
              _buildFloatingIcon('local_drink', Colors.pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(String iconName, Color color) {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: CustomIconWidget(
        iconName: iconName,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      'No Favorite Recipes Yet',
      style: GoogleFonts.inter(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppTheme.textDark,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(bool isDark) {
    return Text(
      'Start favoriting recipes to see them here.\nDiscover amazing dishes and save your favorites for quick access!',
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.mediumGray,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(bool isDark) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onExploreRecipes?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'explore',
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Text(
            'Explore Recipes',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}