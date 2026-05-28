import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item data for the bottom bar
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom bottom navigation bar variants for the culinary application
enum CustomBottomBarVariant {
  /// Standard bottom navigation with 4-5 items
  standard,

  /// Cooking mode bottom bar with cooking-specific actions
  cooking,

  /// Floating bottom bar with elevated appearance
  floating,
}

/// A custom bottom navigation bar widget that provides consistent styling
/// and functionality across the culinary application.
class CustomBottomBar extends StatelessWidget {
  /// The current selected index
  final int currentIndex;

  /// Callback when a navigation item is tapped
  final ValueChanged<int>? onTap;

  /// The variant of the bottom bar to display
  final CustomBottomBarVariant variant;

  /// Background color override
  final Color? backgroundColor;

  /// Selected item color override
  final Color? selectedItemColor;

  /// Unselected item color override
  final Color? unselectedItemColor;

  /// Elevation override
  final double? elevation;

  /// Whether to show labels
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.showLabels = true,
  });

  /// Navigation items for standard variant
  static const List<BottomNavItem> _standardItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/home-screen',
    ),
    BottomNavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Search',
      route: '/search-screen',
    ),
    BottomNavItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favorites',
      route: '/favorites-screen',
    ),
    BottomNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Planner',
      route: '/meal-planner-screen',
    ),
    BottomNavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Shopping',
      route: '/shopping-list-screen',
    ),
  ];

  /// Navigation items for cooking variant
  static const List<BottomNavItem> _cookingItems = [
    BottomNavItem(
      icon: Icons.list_outlined,
      activeIcon: Icons.list,
      label: 'Steps',
      route: '/cooking-mode-screen',
    ),
    BottomNavItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      label: 'Timer',
      route: '/cooking-mode-screen',
    ),
    BottomNavItem(
      icon: Icons.kitchen_outlined,
      activeIcon: Icons.kitchen,
      label: 'Tools',
      route: '/cooking-mode-screen',
    ),
    BottomNavItem(
      icon: Icons.notes_outlined,
      activeIcon: Icons.notes,
      label: 'Notes',
      route: '/cooking-mode-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (variant) {
      case CustomBottomBarVariant.cooking:
        return _buildCookingBottomBar(context, theme, isDark);
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme, isDark);
      case CustomBottomBarVariant.standard:
      default:
        return _buildStandardBottomBar(context, theme, isDark);
    }
  }

  /// Builds the standard bottom navigation bar
  Widget _buildStandardBottomBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? const Color(0xFF2D3748) : Colors.white),
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
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _standardItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return _buildNavItem(
                context,
                item,
                isSelected,
                index,
                isDark,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Builds the cooking mode bottom bar
  Widget _buildCookingBottomBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? const Color(0xFF2D3748) : Colors.white),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : Colors.black).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _cookingItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return _buildCookingNavItem(
                context,
                item,
                isSelected,
                index,
                isDark,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Builds the floating bottom bar
  Widget _buildFloatingBottomBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark ? const Color(0xFF2D3748) : Colors.white),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.black)
                    .withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _standardItems
                    .take(4)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = currentIndex == index;

                  return _buildFloatingNavItem(
                    context,
                    item,
                    isSelected,
                    index,
                    isDark,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a standard navigation item
  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    bool isSelected,
    int index,
    bool isDark,
  ) {
    final selectedColor = selectedItemColor ?? const Color(0xFFFF8A00);
    final unselectedColor = unselectedItemColor ?? const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!(index);
        } else {
          Navigator.pushNamed(context, item.route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
            ),
            if (showLabels) ...[
              const SizedBox(height: 2),
              Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a cooking mode navigation item
  Widget _buildCookingNavItem(
    BuildContext context,
    BottomNavItem item,
    bool isSelected,
    int index,
    bool isDark,
  ) {
    final selectedColor = selectedItemColor ?? const Color(0xFFFF8A00);
    final unselectedColor = unselectedItemColor ?? const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: selectedColor.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? (item.activeIcon ?? item.icon) : item.icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a floating navigation item
  Widget _buildFloatingNavItem(
    BuildContext context,
    BottomNavItem item,
    bool isSelected,
    int index,
    bool isDark,
  ) {
    final selectedColor = selectedItemColor ?? const Color(0xFFFF8A00);
    final unselectedColor = unselectedItemColor ?? const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!(index);
        } else {
          Navigator.pushNamed(context, item.route);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? (item.activeIcon ?? item.icon) : item.icon,
              color: isSelected ? Colors.white : unselectedColor,
              size: 24,
            ),
            if (isSelected && showLabels) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
