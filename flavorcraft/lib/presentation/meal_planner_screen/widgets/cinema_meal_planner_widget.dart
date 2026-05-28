import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CinemaMealPlannerWidget extends StatefulWidget {
  final DateTime currentWeekStart;
  final Map<String, Map<String, Map<String, dynamic>>> weekMeals;
  final Function(int dayIndex, String mealType)? onAddRecipe;
  final Function(String recipeId, int dayIndex, String mealType)?
      onRecipeSelected;
  final Function(String recipeId, int dayIndex, String mealType)?
      onRecipeLongPress;

  const CinemaMealPlannerWidget({
    super.key,
    required this.currentWeekStart,
    required this.weekMeals,
    this.onAddRecipe,
    this.onRecipeSelected,
    this.onRecipeLongPress,
  });

  @override
  State<CinemaMealPlannerWidget> createState() =>
      _CinemaMealPlannerWidgetState();
}

class _CinemaMealPlannerWidgetState extends State<CinemaMealPlannerWidget>
    with TickerProviderStateMixin {
  late AnimationController _screenController;
  late AnimationController _seatController;
  late Animation<double> _screenAnimation;
  late Animation<double> _seatAnimation;

  Set<String> _selectedSeats = {};
  String? _hoveredSeat;

  @override
  void initState() {
    super.initState();
    _screenController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _seatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _screenAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _screenController, curve: Curves.easeOutCubic),
    );
    _seatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _seatController, curve: Curves.elasticOut),
    );

    _screenController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _seatController.forward();
    });
  }

  @override
  void dispose() {
    _screenController.dispose();
    _seatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCinemaScreen(context, theme, isDark),
          SizedBox(height: 4.h),
          _buildAuditoriumSeating(context, theme, isDark),
          SizedBox(height: 3.h),
          _buildLegend(context, theme, isDark),
          if (_selectedSeats.isNotEmpty) ...[
            SizedBox(height: 3.h),
            _buildBookingConfirmation(context, theme, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildCinemaScreen(
      BuildContext context, ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: _screenAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _screenAnimation.value,
          child: Container(
            width: double.infinity,
            height: 8.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4A90E2).withValues(alpha: 0.8),
                  Color(0xFF357ABD).withValues(alpha: 0.6),
                  Color(0xFF2C5F8B).withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4A90E2).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MEAL PLANNER SCREEN',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Select your weekly meal slots',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
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

  Widget _buildAuditoriumSeating(
      BuildContext context, ThemeData theme, bool isDark) {
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

    return AnimatedBuilder(
      animation: _seatAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _seatAnimation.value,
          child: Column(
            children: [
              // Row labels (like cinema row letters)
              ...mealTypes.asMap().entries.map((entry) {
                final mealIndex = entry.key;
                final mealType = entry.value;
                final rowLetter =
                    String.fromCharCode(65 + mealIndex); // A, B, C

                return Container(
                  margin: EdgeInsets.only(bottom: 3.h),
                  child: Column(
                    children: [
                      // Row header with meal type and letter
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            vertical: 1.5.h, horizontal: 4.w),
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              _getMealColor(mealType).withValues(alpha: 0.2),
                              _getMealColor(mealType).withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _getMealColor(mealType).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Row letter (like cinema seating)
                            Container(
                              width: 12.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: _getMealColor(mealType),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getMealColor(mealType)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  rowLetter,
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            // Meal type info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: _getMealIcon(mealType),
                                        color: _getMealColor(mealType),
                                        size: 24,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        mealType.toUpperCase(),
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    'Row $rowLetter • 7 meal slots available',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Seat row
                      _buildSeatRow(
                          context, theme, mealType, mealIndex, rowLetter),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeatRow(BuildContext context, ThemeData theme, String mealType,
      int mealIndex, String rowLetter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (dayIndex) {
        final seatNumber = '${rowLetter}${dayIndex + 1}';
        final dayKey = 'day_$dayIndex';
        final mealData = widget.weekMeals[dayKey]?[mealType.toLowerCase()];
        final isEmpty = mealData == null;
        final isSelected = _selectedSeats.contains(seatNumber);
        final isHovered = _hoveredSeat == seatNumber;
        final currentDate =
            widget.currentWeekStart.add(Duration(days: dayIndex));
        final dayName = _getDayName(dayIndex);

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (isEmpty) {
              widget.onAddRecipe?.call(dayIndex, mealType);
            } else {
              setState(() {
                if (isSelected) {
                  _selectedSeats.remove(seatNumber);
                } else {
                  _selectedSeats.add(seatNumber);
                }
              });
              widget.onRecipeSelected?.call(mealData['id'], dayIndex, mealType);
            }
          },
          onLongPress: () {
            if (!isEmpty) {
              HapticFeedback.heavyImpact();
              widget.onRecipeLongPress
                  ?.call(mealData['id'], dayIndex, mealType);
            }
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredSeat = seatNumber),
            onExit: (_) => setState(() => _hoveredSeat = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 11.w,
              height: 11.w,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                color: _getSeatColor(isEmpty, isSelected, isHovered, mealType),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getSeatBorderColor(
                      isEmpty, isSelected, isHovered, mealType),
                  width: isSelected || isHovered ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected || isHovered)
                    BoxShadow(
                      color: _getMealColor(mealType).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Stack(
                children: [
                  if (!isEmpty && mealData['image'] != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImageWidget(
                          imageUrl: mealData['image'],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (!isEmpty)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      child: Column(
                        mainAxisAlignment: isEmpty
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceBetween,
                        children: [
                          // Seat number (top)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 1.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: isEmpty
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : _getMealColor(mealType)
                                      .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              seatNumber,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 9.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (isEmpty) ...[
                            CustomIconWidget(
                              iconName: 'add',
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ] else ...[
                            // Recipe indicator (bottom)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 1.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 2.w,
                                    height: 2.w,
                                    decoration: BoxDecoration(
                                      color: _getMealColor(mealType),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  if (isSelected)
                                    CustomIconWidget(
                                      iconName: 'check_circle',
                                      color: AppTheme.successGreen,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Tooltip on hover
                  if (isHovered)
                    Positioned(
                      bottom: -6.h,
                      left: -2.w,
                      right: -2.w,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isEmpty
                                  ? 'Available Slot'
                                  : mealData['name'] ?? 'Recipe',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '$dayName, ${currentDate.day}/${currentDate.month}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 8.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLegend(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'SEAT LEGEND',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                  context, theme, 'Available', Colors.grey.shade600, 'add'),
              _buildLegendItem(context, theme, 'Booked', AppTheme.accentOrange,
                  'restaurant'),
              _buildLegendItem(context, theme, 'Selected',
                  AppTheme.successGreen, 'check_circle'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, ThemeData theme, String label,
      Color color, String icon) {
    return Column(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingConfirmation(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.successGreen.withValues(alpha: 0.2),
            AppTheme.successGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'confirmation_number',
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOOKING CONFIRMATION',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${_selectedSeats.length} meal slots selected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Seats: ${_selectedSeats.join(', ')}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSeats.clear();
                    });
                    HapticFeedback.lightImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Clear Selection',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    // Navigate to recipe detail or perform booking action
                    setState(() {
                      _selectedSeats.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Confirm Booking',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayIndex) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return dayNames[dayIndex];
  }

  String _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'free_breakfast';
      case 'lunch':
        return 'lunch_dining';
      case 'dinner':
        return 'dinner_dining';
      default:
        return 'restaurant';
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return AppTheme.accentOrange;
      case 'lunch':
        return AppTheme.primaryGreen;
      case 'dinner':
        return Colors.deepPurple;
      default:
        return AppTheme.mediumGray;
    }
  }

  Color _getSeatColor(
      bool isEmpty, bool isSelected, bool isHovered, String mealType) {
    if (isEmpty) {
      if (isHovered) {
        return Colors.grey.shade500;
      }
      return Colors.grey.shade600;
    }

    if (isSelected) {
      return AppTheme.successGreen;
    }

    if (isHovered) {
      return _getMealColor(mealType).withValues(alpha: 0.8);
    }

    return _getMealColor(mealType).withValues(alpha: 0.6);
  }

  Color _getSeatBorderColor(
      bool isEmpty, bool isSelected, bool isHovered, String mealType) {
    if (isEmpty) {
      if (isHovered) {
        return Colors.grey.shade400;
      }
      return Colors.grey.shade500;
    }

    if (isSelected) {
      return AppTheme.successGreen;
    }

    if (isHovered) {
      return _getMealColor(mealType);
    }

    return _getMealColor(mealType).withValues(alpha: 0.8);
  }
}