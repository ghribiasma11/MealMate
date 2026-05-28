import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialSearchText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onVoicePressed;
  final VoidCallback? onClearPressed;
  final bool isListening;

  const SearchBarWidget({
    super.key,
    this.initialSearchText,
    this.onSearchChanged,
    this.onVoicePressed,
    this.onClearPressed,
    this.isListening = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSearchText);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isListening) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.softBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.mediumGray : AppTheme.lightGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDark.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.mediumGray,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearchChanged,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Search recipes, ingredients...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.mediumGray,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _controller.clear();
                widget.onClearPressed?.call();
                widget.onSearchChanged?.call('');
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                child: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.mediumGray,
                  size: 18,
                ),
              ),
            ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onVoicePressed?.call();
            },
            child: Container(
              padding: EdgeInsets.all(3.w),
              margin: EdgeInsets.only(right: 2.w),
              decoration: BoxDecoration(
                color: widget.isListening
                    ? AppTheme.accentOrange.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isListening ? _pulseAnimation.value : 1.0,
                    child: CustomIconWidget(
                      iconName: widget.isListening ? 'mic' : 'mic_none',
                      color: widget.isListening
                          ? AppTheme.accentOrange
                          : AppTheme.mediumGray,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}