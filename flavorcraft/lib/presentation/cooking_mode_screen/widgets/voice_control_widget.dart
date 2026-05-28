import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class VoiceControlWidget extends StatefulWidget {
  final bool isListening;
  final VoidCallback? onToggleListening;
  final VoidCallback? onEmergencyCall;

  const VoiceControlWidget({
    super.key,
    required this.isListening,
    this.onToggleListening,
    this.onEmergencyCall,
  });

  @override
  State<VoiceControlWidget> createState() => _VoiceControlWidgetState();
}

class _VoiceControlWidgetState extends State<VoiceControlWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceControlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.black).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice control header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'mic',
                  color: AppTheme.accentOrange,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Voice Control',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: widget.isListening,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    widget.onToggleListening?.call();
                  },
                  activeColor: AppTheme.accentOrange,
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Voice commands list
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.softBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Commands:',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildVoiceCommand(
                      'Next Step', 'Move to the next cooking step'),
                  _buildVoiceCommand(
                      'Previous Step', 'Go back to previous step'),
                  _buildVoiceCommand('Start Timer', 'Start the step timer'),
                  _buildVoiceCommand(
                      'Repeat Instructions', 'Read current step again'),
                  _buildVoiceCommand(
                      'Show Ingredients', 'Display ingredient list'),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Control buttons
            Row(
              children: [
                // Voice toggle button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onToggleListening?.call();
                    },
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale:
                              widget.isListening ? _pulseAnimation.value : 1.0,
                          child: Container(
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: widget.isListening
                                  ? AppTheme.accentOrange
                                  : (isDark
                                      ? AppTheme.cardDark
                                      : AppTheme.softBackground),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.isListening
                                    ? AppTheme.accentOrange
                                    : AppTheme.lightGray,
                                width: 2,
                              ),
                              boxShadow: widget.isListening
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.accentOrange
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName:
                                      widget.isListening ? 'mic' : 'mic_off',
                                  color: widget.isListening
                                      ? AppTheme.pureWhite
                                      : AppTheme.mediumGray,
                                  size: 24,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  widget.isListening
                                      ? 'Listening...'
                                      : 'Tap to Listen',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isListening
                                        ? AppTheme.pureWhite
                                        : AppTheme.mediumGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                // Emergency call button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      widget.onEmergencyCall?.call();
                    },
                    child: Container(
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.errorRed.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'phone',
                            color: AppTheme.pureWhite,
                            size: 20,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Emergency',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.pureWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCommand(String command, String description) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Container(
            width: 1.w,
            height: 1.w,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange,
              borderRadius: BorderRadius.circular(0.5.w),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$command"',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}