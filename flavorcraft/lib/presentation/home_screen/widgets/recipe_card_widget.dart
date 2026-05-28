import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class RecipeCardWidget extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onLongPress;

  const RecipeCardWidget({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onLongPress,
  });

  @override
  State<RecipeCardWidget> createState() => _RecipeCardWidgetState();
}

class _RecipeCardWidgetState extends State<RecipeCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recipe = widget.recipe;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              widget.onLongPress();
            },
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              margin: EdgeInsets.only(bottom: 4.w),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.black)
                        .withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Image with Favorite Button
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CustomImageWidget(
                          imageUrl: recipe["image"] as String,
                          width: double.infinity,
                          height: (recipe["id"] as int) % 3 == 0 ? 25.h : 20.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient overlay for text readability
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Favorite Button
                      Positioned(
                        top: 2.w,
                        right: 2.w,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onFavoriteToggle();
                          },
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.pureWhite.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CustomIconWidget(
                              iconName: (recipe["isFavorite"] as bool)
                                  ? 'favorite'
                                  : 'favorite_border',
                              color: (recipe["isFavorite"] as bool)
                                  ? AppTheme.errorRed
                                  : AppTheme.mediumGray,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // Difficulty Badge
                      Positioned(
                        top: 2.w,
                        left: 2.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.w,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(
                                    recipe["difficulty"] as String)
                                .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recipe["difficulty"] as String,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.pureWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Recipe Details
                  Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipe Title
                        Text(
                          recipe["title"] as String,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.pureWhite
                                : AppTheme.textDark,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        // Recipe Metadata
                        Row(
                          children: [
                            // Prep Time
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: AppTheme.mediumGray,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              "${recipe["prepTime"]} min",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.mediumGray,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            // Rating Stars
                            Row(
                              children: List.generate(5, (index) {
                                final rating = recipe["rating"] as double;
                                return CustomIconWidget(
                                  iconName: index < rating.floor()
                                      ? 'star'
                                      : (index < rating
                                          ? 'star_half'
                                          : 'star_border'),
                                  color: AppTheme.accentOrange,
                                  size: 14,
                                );
                              }),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              "${recipe["rating"]}",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        // Category and Servings
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                recipe["category"] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'people',
                                  color: AppTheme.mediumGray,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  "${recipe["servings"]} servings",
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.mediumGray,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.successGreen;
      case 'medium':
        return AppTheme.accentOrange;
      case 'hard':
        return AppTheme.errorRed;
      default:
        return AppTheme.mediumGray;
    }
  }
}