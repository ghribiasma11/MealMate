import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_export.dart';

class RecipeInfoSection extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final int servingSize;
  final ValueChanged<int> onServingSizeChanged;

  const RecipeInfoSection({
    super.key,
    required this.recipe,
    required this.servingSize,
    required this.onServingSizeChanged,
  });

  @override
  State<RecipeInfoSection> createState() => _RecipeInfoSectionState();
}

class _RecipeInfoSectionState extends State<RecipeInfoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _servingController;
  late Animation<double> _servingAnimation;

  @override
  void initState() {
    super.initState();
    _servingController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _servingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _servingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _servingController.dispose();
    super.dispose();
  }

  void _updateServingSize(int newSize) {
    if (newSize >= 1 && newSize <= 12) {
      HapticFeedback.lightImpact();
      _servingController.forward().then((_) {
        _servingController.reverse();
      });
      widget.onServingSizeChanged(newSize);
    }
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.accentOrange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? AppTheme.accentOrange).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon.codePoint.toString(),
            color: color ?? AppTheme.accentOrange,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.accentOrange,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Title
          Text(
            widget.recipe['title'] as String,
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textDark,
              height: 1.2,
            ),
          ),

          SizedBox(height: 2.h),

          // Recipe Description
          if (widget.recipe['description'] != null)
            Text(
              widget.recipe['description'] as String,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.mediumGray,
                height: 1.4,
              ),
            ),

          SizedBox(height: 4.h),

          // Recipe Info Chips
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.access_time,
                  label: 'Prep Time',
                  value: '${widget.recipe['prepTime']}min',
                  color: AppTheme.accentOrange,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.local_fire_department,
                  label: 'Difficulty',
                  value: widget.recipe['difficulty'] as String,
                  color: AppTheme.errorRed,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.star,
                  label: 'Rating',
                  value: '${widget.recipe['rating']}',
                  color: AppTheme.accentOrange,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Serving Size Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Serving Size',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              AnimatedBuilder(
                animation: _servingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _servingAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accentOrange.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () =>
                                _updateServingSize(widget.servingSize - 1),
                            icon: CustomIconWidget(
                              iconName: 'remove',
                              color: AppTheme.accentOrange,
                              size: 20,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              '${widget.servingSize}',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _updateServingSize(widget.servingSize + 1),
                            icon: CustomIconWidget(
                              iconName: 'add',
                              color: AppTheme.accentOrange,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}