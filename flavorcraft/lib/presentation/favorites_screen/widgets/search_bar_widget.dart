import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    this.initialQuery,
    this.onSearchChanged,
    this.onClear,
  });

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _controller.clear();
        widget.onSearchChanged?.call('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isExpanded ? 8.h : 0,
      child:
          _isExpanded ? _buildExpandedSearch(isDark) : const SizedBox.shrink(),
    );
  }

  Widget _buildExpandedSearch(bool isDark) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.softBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppTheme.mediumGray.withValues(alpha: 0.3)
                : AppTheme.lightGray,
            width: 1,
          ),
        ),
        child: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: 'Search your favorite recipes...',
            hintStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.mediumGray,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'search',
                color: AppTheme.mediumGray,
                size: 20,
              ),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _controller.clear();
                      widget.onSearchChanged?.call('');
                    },
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.mediumGray,
                        size: 20,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _toggleSearch();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.mediumGray,
                        size: 20,
                      ),
                    ),
                  ),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
          onChanged: (value) {
            setState(() {});
            widget.onSearchChanged?.call(value);
          },
        ),
      ),
    );
  }

  // Method to be called from parent to show search
  void showSearch() {
    if (!_isExpanded) {
      _toggleSearch();
    }
  }

  // Method to be called from parent to hide search
  void hideSearch() {
    if (_isExpanded) {
      _toggleSearch();
    }
  }
}