import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab item data for the custom tab bar
class CustomTabItem {
  final String label;
  final IconData? icon;
  final Color? color;
  final String? route;

  const CustomTabItem({
    required this.label,
    this.icon,
    this.color,
    this.route,
  });
}

/// Custom tab bar variants for the culinary application
enum CustomTabBarVariant {
  /// Standard tab bar with text labels
  standard,

  /// Category tab bar with colored indicators for recipe categories
  category,

  /// Icon tab bar with icons and labels
  iconLabel,

  /// Chip-style tab bar with rounded background
  chip,
}

/// A custom tab bar widget that provides consistent styling and functionality
/// across the culinary application with support for different variants.
class CustomTabBar extends StatelessWidget {
  /// List of tab items
  final List<CustomTabItem> tabs;

  /// Current selected index
  final int currentIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int>? onTap;

  /// The variant of the tab bar to display
  final CustomTabBarVariant variant;

  /// Whether the tab bar is scrollable
  final bool isScrollable;

  /// Background color override
  final Color? backgroundColor;

  /// Selected tab color override
  final Color? selectedColor;

  /// Unselected tab color override
  final Color? unselectedColor;

  /// Indicator color override
  final Color? indicatorColor;

  /// Tab padding
  final EdgeInsets? tabPadding;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.onTap,
    this.variant = CustomTabBarVariant.standard,
    this.isScrollable = false,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.tabPadding,
  });

  /// Predefined recipe category tabs
  static const List<CustomTabItem> recipeCategoryTabs = [
    CustomTabItem(
      label: 'All',
      icon: Icons.restaurant,
      color: Color(0xFF64748B),
    ),
    CustomTabItem(
      label: 'Breakfast',
      icon: Icons.free_breakfast,
      color: Color(0xFFFF8A00),
    ),
    CustomTabItem(
      label: 'Healthy',
      icon: Icons.eco,
      color: Color(0xFF4CAF50),
    ),
    CustomTabItem(
      label: 'Desserts',
      icon: Icons.cake,
      color: Color(0xFF7B1FA2),
    ),
    CustomTabItem(
      label: 'Beverages',
      icon: Icons.local_drink,
      color: Color(0xFFE91E63),
    ),
  ];

  /// Predefined meal planner tabs
  static const List<CustomTabItem> mealPlannerTabs = [
    CustomTabItem(
      label: 'Today',
      icon: Icons.today,
    ),
    CustomTabItem(
      label: 'Week',
      icon: Icons.view_week,
    ),
    CustomTabItem(
      label: 'Month',
      icon: Icons.calendar_month,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (variant) {
      case CustomTabBarVariant.category:
        return _buildCategoryTabBar(context, theme, isDark);
      case CustomTabBarVariant.iconLabel:
        return _buildIconLabelTabBar(context, theme, isDark);
      case CustomTabBarVariant.chip:
        return _buildChipTabBar(context, theme, isDark);
      case CustomTabBarVariant.standard:
      default:
        return _buildStandardTabBar(context, theme, isDark);
    }
  }

  /// Builds the standard tab bar variant
  Widget _buildStandardTabBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      color:
          backgroundColor ?? (isDark ? const Color(0xFF1A202C) : Colors.white),
      child: TabBar(
        tabs: tabs.map((tab) => Tab(text: tab.label)).toList(),
        isScrollable: isScrollable,
        labelColor: selectedColor ?? const Color(0xFFFF8A00),
        unselectedLabelColor: unselectedColor ?? const Color(0xFF64748B),
        indicatorColor: indicatorColor ?? const Color(0xFFFF8A00),
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        padding: tabPadding ?? const EdgeInsets.symmetric(horizontal: 16),
        onTap: (index) {
          HapticFeedback.lightImpact();
          if (onTap != null) {
            onTap!(index);
          } else if (tabs[index].route != null) {
            Navigator.pushNamed(context, tabs[index].route!);
          }
        },
      ),
    );
  }

  /// Builds the category tab bar variant with colored indicators
  Widget _buildCategoryTabBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      height: 60,
      color:
          backgroundColor ?? (isDark ? const Color(0xFF1A202C) : Colors.white),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = currentIndex == index;
          final tabColor = tab.color ?? const Color(0xFF64748B);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (onTap != null) {
                onTap!(index);
              } else if (tab.route != null) {
                Navigator.pushNamed(context, tab.route!);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? tabColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? tabColor : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tab.icon != null) ...[
                    Icon(
                      tab.icon,
                      color: isSelected ? tabColor : const Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    tab.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? tabColor : const Color(0xFF64748B),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the icon label tab bar variant
  Widget _buildIconLabelTabBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      color:
          backgroundColor ?? (isDark ? const Color(0xFF1A202C) : Colors.white),
      child: TabBar(
        tabs: tabs
            .map((tab) => Tab(
                  icon: tab.icon != null ? Icon(tab.icon, size: 24) : null,
                  text: tab.label,
                ))
            .toList(),
        isScrollable: isScrollable,
        labelColor: selectedColor ?? const Color(0xFFFF8A00),
        unselectedLabelColor: unselectedColor ?? const Color(0xFF64748B),
        indicatorColor: indicatorColor ?? const Color(0xFFFF8A00),
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        padding: tabPadding ?? const EdgeInsets.symmetric(horizontal: 16),
        onTap: (index) {
          HapticFeedback.lightImpact();
          if (onTap != null) {
            onTap!(index);
          } else if (tabs[index].route != null) {
            Navigator.pushNamed(context, tabs[index].route!);
          }
        },
      ),
    );
  }

  /// Builds the chip-style tab bar variant
  Widget _buildChipTabBar(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      height: 50,
      color:
          backgroundColor ?? (isDark ? const Color(0xFF1A202C) : Colors.white),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = currentIndex == index;
          final chipColor = selectedColor ?? const Color(0xFFFF8A00);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (onTap != null) {
                onTap!(index);
              } else if (tab.route != null) {
                Navigator.pushNamed(context, tab.route!);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? chipColor
                    : (isDark
                        ? const Color(0xFF2D3748)
                        : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? chipColor : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: chipColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tab.icon != null) ...[
                    Icon(
                      tab.icon,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    tab.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A wrapper widget that provides TabController functionality for CustomTabBar
class CustomTabBarView extends StatefulWidget {
  /// List of tab items
  final List<CustomTabItem> tabs;

  /// List of widgets to display for each tab
  final List<Widget> children;

  /// The variant of the tab bar to display
  final CustomTabBarVariant variant;

  /// Initial selected index
  final int initialIndex;

  /// Whether the tab bar is scrollable
  final bool isScrollable;

  /// Callback when tab changes
  final ValueChanged<int>? onTabChanged;

  const CustomTabBarView({
    super.key,
    required this.tabs,
    required this.children,
    this.variant = CustomTabBarVariant.standard,
    this.initialIndex = 0,
    this.isScrollable = false,
    this.onTabChanged,
  });

  @override
  State<CustomTabBarView> createState() => _CustomTabBarViewState();
}

class _CustomTabBarViewState extends State<CustomTabBarView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (widget.onTabChanged != null) {
      widget.onTabChanged!(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTabBar(
          tabs: widget.tabs,
          currentIndex: _tabController.index,
          variant: widget.variant,
          isScrollable: widget.isScrollable,
          onTap: (index) {
            _tabController.animateTo(index);
          },
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
