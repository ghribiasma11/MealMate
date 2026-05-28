import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class RecentSearchesWidget extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String>? onSearchTap;
  final ValueChanged<String>? onRemoveSearch;

  const RecentSearchesWidget({
    super.key,
    required this.recentSearches,
    this.onSearchTap,
    this.onRemoveSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Clear all recent searches
                  for (String search in recentSearches) {
                    onRemoveSearch?.call(search);
                  }
                },
                child: Text(
                  'Clear All',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: recentSearches.map((search) {
              return _buildSearchChip(search, isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String search, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onSearchTap?.call(search);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
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
              iconName: 'history',
              color: AppTheme.mediumGray,
              size: 16,
            ),
            SizedBox(width: 2.w),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 40.w),
              child: Text(
                search,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onRemoveSearch?.call(search);
              },
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.mediumGray,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}