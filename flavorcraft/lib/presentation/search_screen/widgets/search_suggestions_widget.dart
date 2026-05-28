import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class SearchSuggestionsWidget extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestionTap;

  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(12),
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length > 5 ? 5 : suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? AppTheme.mediumGray : AppTheme.lightGray,
        ),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return _buildSuggestionItem(suggestion, isDark);
        },
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onSuggestionTap?.call(suggestion);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'search',
              color: AppTheme.mediumGray,
              size: 18,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                suggestion,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            CustomIconWidget(
              iconName: 'north_west',
              color: AppTheme.mediumGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}