import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class RecipeHeroSection extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onSharePressed;

  const RecipeHeroSection({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onSharePressed,
  });

  @override
  State<RecipeHeroSection> createState() => _RecipeHeroSectionState();
}

class _RecipeHeroSectionState extends State<RecipeHeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _favoriteController;
  late Animation<double> _favoriteAnimation;
  PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onFavoritePressed() {
    HapticFeedback.lightImpact();
    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });
    widget.onFavoritePressed();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.recipe['images'] as List<String>? ??
        [widget.recipe['image'] as String];

    return SizedBox(
      height: 85.h,
      child: Stack(
        children: [
          // Hero Image with Gallery
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return CustomImageWidget(
                imageUrl: images[index],
                width: double.infinity,
                height: 85.h,
                fit: BoxFit.cover,
              );
            },
          ),

          // Gradient Overlay
          Container(
            height: 85.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // App Bar with Back and Share Icons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        icon: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Share Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onSharePressed();
                        },
                        icon: CustomIconWidget(
                          iconName: 'share',
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Favorite Button
          Positioned(
            bottom: 4.h,
            right: 6.w,
            child: AnimatedBuilder(
              animation: _favoriteAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _favoriteAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _onFavoritePressed,
                      icon: CustomIconWidget(
                        iconName:
                            widget.isFavorite ? 'favorite' : 'favorite_border',
                        color: widget.isFavorite
                            ? AppTheme.errorRed
                            : AppTheme.mediumGray,
                        size: 28,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Image Gallery Indicators
          if (images.length > 1)
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentImageIndex == entry.key ? 8.w : 2.w,
                    height: 1.h,
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    decoration: BoxDecoration(
                      color: _currentImageIndex == entry.key
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}